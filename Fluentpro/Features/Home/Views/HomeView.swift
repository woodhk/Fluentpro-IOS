import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // User Greeting
                    if let user = viewModel.currentUser {
                        VStack(spacing: 8) {
                            Text("Welcome back,")
                                .font(.title2)
                                .foregroundColor(.theme.secondaryText)
                            
                            Text(user.fullName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.primaryText)
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer()
                    
                    // Homepage Text
                    VStack(spacing: 16) {
                        Text("Homepage")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.theme.primaryText)
                        
                        Text("Your journey starts here")
                            .font(.title3)
                            .foregroundColor(.theme.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        viewModel.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.theme.secondaryBackground)
                        .foregroundColor(.theme.error)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.theme.error.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Profile action
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.theme.primaryText)
                    }
                }
            }
            .alert("Logout", isPresented: $viewModel.showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelLogout()
                }
                Button("Logout", role: .destructive) {
                    viewModel.confirmLogout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .onChange(of: viewModel.isLoggedOut) { _, isLoggedOut in
                if isLoggedOut {
                    navigationCoordinator.handleLogout()
                }
            }
            .onAppear {
                viewModel.loadUserData()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthenticationService.shared)
}