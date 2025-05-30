//
//  FluentproApp.swift
//  Fluentpro
//
//  Created by Alex Wood on 30/5/2025.
//

import SwiftUI

@main
struct FluentproApp: App {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch navigationCoordinator.currentView {
                case .login:
                    LoginView()
                case .signUp:
                    SignUpView()
                case .home:
                    HomeView()
                case .onboarding:
                    OnboardingView()
                case .profile:
                    Text("Profile View - Coming Soon")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .environmentObject(navigationCoordinator)
            .environmentObject(authService)
        }
    }
}
