import Foundation
import SwiftUI

enum AppView {
    case onboarding
    case login
    case signUp
    case home
    case profile
}

@MainActor
class NavigationCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentView: AppView = .login
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Private Properties
    private var authToken: AuthToken?
    
    // MARK: - Initialization
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Navigation Methods
    func navigateTo(_ view: AppView) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = view
        }
    }
    
    func navigateToHome() {
        navigationPath.removeLast(navigationPath.count)
        navigateTo(.home)
    }
    
    func navigateToLogin() {
        navigationPath.removeLast(navigationPath.count)
        navigateTo(.login)
    }
    
    func navigateToSignUp() {
        navigateTo(.signUp)
    }
    
    func navigateToOnboarding() {
        navigateTo(.onboarding)
    }
    
    // MARK: - Authentication Methods
    func login(user: User, token: AuthToken) {
        self.currentUser = user
        self.authToken = token
        self.isAuthenticated = true
        saveAuthenticationData(user: user, token: token)
        navigateToHome()
    }
    
    func logout() {
        self.currentUser = nil
        self.authToken = nil
        self.isAuthenticated = false
        clearAuthenticationData()
        navigateToLogin()
    }
    
    func updateUser(_ user: User) {
        self.currentUser = user
        if let token = authToken {
            saveAuthenticationData(user: user, token: token)
        }
    }
    
    // MARK: - Private Methods
    private func checkAuthenticationStatus() {
        // Check if user is already logged in (e.g., from UserDefaults or Keychain)
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let tokenData = UserDefaults.standard.data(forKey: "authToken") {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let user = try decoder.decode(User.self, from: userData)
                let token = try decoder.decode(AuthToken.self, from: tokenData)
                
                // Check if token is still valid
                if token.expiresAt > Date() {
                    self.currentUser = user
                    self.authToken = token
                    self.isAuthenticated = true
                    self.currentView = .home
                } else {
                    // Token expired, clear data and go to login
                    clearAuthenticationData()
                    self.currentView = .login
                }
            } catch {
                print("Error decoding authentication data: \(error)")
                self.currentView = .onboarding
            }
        } else {
            // No authentication data found, show onboarding
            self.currentView = .onboarding
        }
    }
    
    private func saveAuthenticationData(user: User, token: AuthToken) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let userData = try encoder.encode(user)
            let tokenData = try encoder.encode(token)
            
            UserDefaults.standard.set(userData, forKey: "currentUser")
            UserDefaults.standard.set(tokenData, forKey: "authToken")
        } catch {
            print("Error saving authentication data: \(error)")
        }
    }
    
    private func clearAuthenticationData() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}