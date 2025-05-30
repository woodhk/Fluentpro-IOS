import SwiftUI

struct HomeView: View {
    @State private var userName: String? = "John Doe" // Mock user name
    @State private var showLogoutAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // User Greeting
                    if let userName = userName {
                        VStack(spacing: 8) {
                            Text("Welcome back,")
                                .font(.title2)
                                .foregroundColor(.theme.secondaryText)
                            
                            Text(userName)
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
                        showLogoutAlert = true
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
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
    
    private func handleLogout() {
        // Handle logout logic here
        // For now, just dismiss or navigate to login
        // In a real app, you would clear user session, tokens, etc.
    }
}

#Preview {
    HomeView()
}