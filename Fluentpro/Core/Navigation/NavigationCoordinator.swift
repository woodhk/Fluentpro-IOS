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
    // MARK: - Singleton
    static let shared = NavigationCoordinator()
    
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
        print("🏠 handleSuccessfulLogin called - checking onboarding status")
        Task {
            await checkOnboardingStatusAndNavigate()
        }
    }
    
    func handleSuccessfulSignUp() {
        print("🎊 handleSuccessfulSignUp called - navigating to onboarding")
        navigateToOnboarding()
    }
    
    func checkOnboardingStatusAndNavigate() async {
        do {
            let profile = try await authService.getUserProfile()
            print("📊 [NAVIGATION] User onboarding status: \(profile.onboardingStatus)")
            
            await MainActor.run {
                switch profile.onboardingStatus {
                case "completed":
                    print("✅ [NAVIGATION] Onboarding completed - navigating to home")
                    navigateToHome()
                case "pending", "welcome", "basic_info", "personalisation", "course_assignment":
                    print("🎯 [NAVIGATION] Onboarding incomplete - navigating to onboarding")
                    navigateToOnboarding()
                default:
                    print("❓ [NAVIGATION] Unknown onboarding status - navigating to onboarding")
                    navigateToOnboarding()
                }
            }
        } catch {
            print("❌ [NAVIGATION] Failed to get user profile: \(error)")
            // If we can't get the profile, navigate to home as fallback
            await MainActor.run {
                navigateToHome()
            }
        }
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