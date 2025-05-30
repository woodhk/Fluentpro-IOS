//
//  AuthenticationService.swift
//  Fluentpro
//
//  Created on 30/05/2025.
//

import Foundation
import Combine

// MARK: - Authentication Models
struct Auth0CallbackRequest: Encodable {
    let code: String
    let state: String?
}

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}

// MARK: - Authentication Service
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    private let networkService = NetworkService.shared
    private let keychainKey = "com.fluentpro.refreshToken"
    
    // Current user
    @Published private(set) var currentUser: User?
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Login with email and password
    func login(email: String, password: String) async throws -> User {
        let loginRequest = LoginRequest(email: email, password: password)
        
        do {
            let response = try await networkService.post(
                endpoint: .login,
                body: loginRequest,
                responseType: AuthResponse.self
            )
            
            // Store tokens
            networkService.setAuthToken(response.accessToken)
            try saveRefreshToken(response.refreshToken)
            
            // Update current user
            currentUser = response.user
            
            return response.user
        } catch {
            throw AuthenticationError.loginFailed(error)
        }
    }
    
    /// Sign up with email and password
    func signUp(fullName: String, email: String, password: String, dateOfBirth: Date) async throws -> User {
        let signUpRequest = SignUpRequest(
            fullName: fullName,
            email: email,
            password: password,
            dateOfBirth: dateOfBirth
        )
        
        do {
            let response = try await networkService.post(
                endpoint: .signup,
                body: signUpRequest,
                responseType: AuthResponse.self
            )
            
            // Store tokens
            networkService.setAuthToken(response.accessToken)
            try saveRefreshToken(response.refreshToken)
            
            // Update current user
            currentUser = response.user
            
            return response.user
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
            try saveRefreshToken(response.refreshToken)
            
            // Update current user
            currentUser = response.user
            
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
        currentUser = nil
        
        // Optionally call logout endpoint to invalidate tokens on server
        Task {
            try? await networkService.post(endpoint: .logout, responseType: EmptyResponse.self)
        }
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return networkService.getAuthToken() != nil && currentUser != nil
    }
    
    /// Get current access token
    func getAccessToken() -> String? {
        return networkService.getAuthToken()
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
    case signUpFailed(Error)
    case auth0CallbackFailed(Error)
    case refreshTokenFailed(Error)
    case noRefreshToken
    case keychainError
    
    var errorDescription: String? {
        switch self {
        case .loginFailed(let error):
            return "Login failed: \(error.localizedDescription)"
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

