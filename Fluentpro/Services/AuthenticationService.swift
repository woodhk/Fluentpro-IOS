//
//  AuthenticationService.swift
//  Fluentpro
//
//  Created on 30/05/2025.
//

import Foundation
import Combine

// MARK: - Authentication Service
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    private let networkService = NetworkService.shared
    private let keychainKey = "com.fluentpro.refreshToken"
    
    // Current user
    @Published private(set) var currentUser: User?
    
    private init() {
        // Check for existing authentication on init
        Task {
            await checkStoredAuthentication()
        }
    }
    
    // MARK: - Public Methods
    
    /// Login with email and password
    func login(email: String, password: String) async throws -> User {
        print("🔐 [AUTH] Login attempt for: \(email)")
        print("🔐 [AUTH] Login endpoint: \(APIEndpoints.login.url?.absoluteString ?? "nil")")
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        do {
            let response = try await networkService.post(
                endpoint: .login,
                body: loginRequest,
                responseType: AuthResponse.self
            )
            
            print("🔐 [AUTH] Response received")
            print("🔐 [AUTH] Token stored: \(response.accessToken.prefix(20))...")
            print("🔐 [AUTH] User ID: \(response.user.id)")
            
            // Store tokens
            networkService.setAuthToken(response.accessToken)
            if !response.refreshToken.isEmpty {
                try saveRefreshToken(response.refreshToken)
            }
            
            // Update current user
            await MainActor.run {
                currentUser = response.user
            }
            
            return response.user
        } catch let error as NetworkError {
            switch error {
            case .httpError(let statusCode, let data):
                if statusCode == 404 || statusCode == 401 {
                    // User not found or invalid credentials
                    throw AuthenticationError.userNotFound
                }
                // Try to parse error message from response
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                        let message = errorResponse.error ?? errorResponse.details ?? "Login failed"
                        throw AuthenticationError.loginFailedWithMessage(message)
                    } else {
                        throw AuthenticationError.loginFailedWithMessage("Login failed")
                    }
                }
            default:
                break
            }
            throw AuthenticationError.loginFailed(error)
        } catch {
            throw AuthenticationError.loginFailed(error)
        }
    }
    
    /// Sign up with email and password
    func signUp(fullName: String, email: String, password: String, dateOfBirth: Date) async throws -> User {
        print("🔐 [AUTH] Sign up attempt for: \(email)")
        print("🔐 [AUTH] Sign up endpoint: \(APIEndpoints.signup.url?.absoluteString ?? "nil")")
        // Clear any existing auth state before signup
        networkService.clearAuthToken()
        deleteRefreshToken()
        currentUser = nil
        
        // Format date as YYYY-MM-DD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateOfBirthString = dateFormatter.string(from: dateOfBirth)
        
        let signUpRequest = SignUpRequest(
            fullName: fullName,
            email: email,
            password: password,
            dateOfBirth: dateOfBirthString
        )
        
        do {
            let response = try await networkService.post(
                endpoint: .signup,
                body: signUpRequest,
                responseType: AuthResponse.self
            )
            
            print("🔐 [AUTH] Sign up successful")
            print("🔐 [AUTH] New user ID: \(response.user.id)")
            print("🔐 [AUTH] Token received: \(response.accessToken.prefix(20))...")
            
            // Store tokens
            networkService.setAuthToken(response.accessToken)
            if !response.refreshToken.isEmpty {
                try saveRefreshToken(response.refreshToken)
            }
            
            // Update current user
            await MainActor.run {
                currentUser = response.user
            }
            
            return response.user
        } catch let error as NetworkError {
            switch error {
            case .httpError(let statusCode, let data):
                if statusCode == 409 {
                    // User already exists
                    throw AuthenticationError.loginFailedWithMessage("An account with this email already exists")
                }
                // Try to parse error message from response
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                        let message = errorResponse.error ?? errorResponse.details ?? "Sign up failed"
                        throw AuthenticationError.loginFailedWithMessage(message)
                    }
                }
            default:
                break
            }
            throw AuthenticationError.signUpFailed(error)
        } catch {
            throw AuthenticationError.signUpFailed(error)
        }
    }
    
    /// Handle Auth0 callback
    func handleAuth0Callback(code: String, state: String?) async throws -> User {
        let callbackRequest = Auth0CallbackRequest(code: code, state: state)
        
        do {
            let response = try await networkService.post(
                endpoint: .auth0Callback,
                body: callbackRequest,
                responseType: AuthResponse.self
            )
            
            // Store tokens
            networkService.setAuthToken(response.accessToken)
            if !response.refreshToken.isEmpty {
                try saveRefreshToken(response.refreshToken)
            }
            
            // Update current user
            await MainActor.run {
                currentUser = response.user
            }
            
            return response.user
        } catch {
            throw AuthenticationError.auth0CallbackFailed(error)
        }
    }
    
    /// Refresh access token
    func refreshToken() async throws {
        guard let refreshToken = getRefreshToken() else {
            throw AuthenticationError.noRefreshToken
        }
        
        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        
        do {
            let response = try await networkService.post(
                endpoint: .refreshToken,
                body: refreshRequest,
                responseType: RefreshTokenResponse.self
            )
            
            // Update access token
            networkService.setAuthToken(response.accessToken)
        } catch {
            // If refresh fails, clear all tokens and require re-login
            logout()
            throw AuthenticationError.refreshTokenFailed(error)
        }
    }
    
    /// Logout
    func logout() {
        // Clear tokens
        networkService.clearAuthToken()
        deleteRefreshToken()
        
        // Clear current user
        Task { @MainActor in
            currentUser = nil
        }
        
        // Optionally call logout endpoint to invalidate tokens on server
        Task {
            try? await networkService.post(endpoint: .logout, responseType: EmptyResponse.self)
        }
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return networkService.getAuthToken() != nil && currentUser != nil
    }
    
    /// Check for stored authentication on app launch
    func checkStoredAuthentication() async {
        // Check if we have a stored refresh token
        guard getRefreshToken() != nil,
              networkService.getAuthToken() != nil else {
            return
        }
        
        // Try to refresh the token and get user info
        do {
            try await refreshToken()
            // Get user profile - just get basic user info for now
            let profile = try await getUserProfile()
            await MainActor.run {
                self.currentUser = profile.user
            }
        } catch {
            // If refresh fails, clear authentication
            await MainActor.run {
                self.logout()
            }
        }
    }
    
    /// Get current access token
    func getAccessToken() -> String? {
        return networkService.getAuthToken()
    }
    
    /// Get user profile with onboarding status
    func getUserProfile() async throws -> UserProfile {
        return try await networkService.get(
            endpoint: .userProfile,
            responseType: UserProfile.self
        )
    }
    
    // MARK: - Private Methods
    
    private func saveRefreshToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthenticationError.keychainError
        }
    }
    
    private func getRefreshToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    private func deleteRefreshToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Authentication Errors
enum AuthenticationError: LocalizedError {
    case loginFailed(Error)
    case loginFailedWithMessage(String)
    case userNotFound
    case signUpFailed(Error)
    case auth0CallbackFailed(Error)
    case refreshTokenFailed(Error)
    case noRefreshToken
    case keychainError
    
    var errorDescription: String? {
        switch self {
        case .loginFailed(let error):
            return "Login failed: \(error.localizedDescription)"
        case .loginFailedWithMessage(let message):
            return message
        case .userNotFound:
            return "No account found with these credentials. Please sign up to create an account."
        case .signUpFailed(let error):
            return "Sign up failed: \(error.localizedDescription)"
        case .auth0CallbackFailed(let error):
            return "Auth0 authentication failed: \(error.localizedDescription)"
        case .refreshTokenFailed(let error):
            return "Token refresh failed: \(error.localizedDescription)"
        case .noRefreshToken:
            return "No refresh token available"
        case .keychainError:
            return "Failed to access secure storage"
        }
    }
}

