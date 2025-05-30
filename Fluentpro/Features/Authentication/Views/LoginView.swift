import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo or App Name
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.primaryText)
                            
                            Text("Sign in to continue")
                                .font(.body)
                                .foregroundColor(.theme.secondaryText)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.theme.secondaryText)
                                
                                TextField("Enter your email", text: $viewModel.email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.theme.secondaryText)
                                
                                SecureField("Enter your password", text: $viewModel.password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.caption)
                                .foregroundColor(.theme.error)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login Button
                        Button(action: {
                            viewModel.login()
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#234BFF"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                        .opacity((viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty) ? 0.6 : 1.0)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.theme.secondaryText)
                            
                            Button("Sign Up") {
                                navigationCoordinator.navigateToSignUp()
                            }
                            .foregroundColor(Color(hex: "#234BFF"))
                            .fontWeight(.medium)
                        }
                        .font(.footnote)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal)
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
            }
            .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
                if isLoggedIn {
                    navigationCoordinator.handleSuccessfulLogin()
                }
            }
            .onChange(of: viewModel.promptSignUp) { _, shouldPrompt in
                if shouldPrompt {
                    navigationCoordinator.navigateToSignUp()
                }
            }
            .alert("No Account Found", isPresented: $viewModel.promptSignUp) {
                Button("Sign Up") {
                    navigationCoordinator.navigateToSignUp()
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing
                }
            } message: {
                Text("It looks like you don't have an account yet. Would you like to sign up?")
            }
        }
    }
}

// Custom TextField Style
struct RoundedBorderTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.theme.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthenticationService.shared)
}