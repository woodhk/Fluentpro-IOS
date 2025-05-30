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
        navigateTo(.onboarding)
    }
    
    // MARK: - Authentication Methods
    func handleSuccessfulLogin() {
        print("🏠 handleSuccessfulLogin called - navigating to home")
        navigateToHome()
    }
    
    func handleSuccessfulSignUp() {
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
                    // User is authenticated, stay on current view or go to home
                    if self?.currentView == .login || self?.currentView == .signUp {
                        // Don't auto-navigate, let the view models handle it
                    }
                } else {
                    // User is not authenticated
                    self?.currentView = .login
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}