import Foundation
import SwiftUI
import Combine

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
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Private Properties
    private let authService = AuthenticationService.shared
    
    // MARK: - Initialization
    init() {
        setupAuthenticationObserver()
    }
    
    // MARK: - Navigation Methods
    func navigateTo(_ view: AppView) {
        print("🧭 navigateTo called with view: \(view)")
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = view
            print("✅ currentView set to: \(currentView)")
        }
    }
    
    func navigateToHome() {
        print("📱 navigateToHome called - clearing path and setting currentView to .home")
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
        print("👋 navigateToOnboarding called")
        navigateTo(.onboarding)
    }
    
    // MARK: - Authentication Methods
    func handleSuccessfulLogin() {
        print("🏠 handleSuccessfulLogin called - navigating to home")
        navigateToHome()
    }
    
    func handleSuccessfulSignUp() {
        print("🎊 handleSuccessfulSignUp called - navigating to onboarding")
        navigateToOnboarding()
    }
    
    func handleLogout() {
        navigateToLogin()
    }
    
    // MARK: - Private Methods
    private func setupAuthenticationObserver() {
        // Observe authentication state changes
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    // User is authenticated
                    // Don't auto-navigate if we're in the middle of signup/onboarding flow
                    if self?.currentView == .login || self?.currentView == .signUp || self?.currentView == .onboarding {
                        // Let the view models handle navigation
                        return
                    }
                } else {
                    // User is not authenticated
                    // Only redirect to login if we're not already there or in signup
                    if self?.currentView != .login && self?.currentView != .signUp {
                        self?.currentView = .login
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}