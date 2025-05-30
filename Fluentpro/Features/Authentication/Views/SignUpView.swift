import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var authService: AuthenticationService
    @State private var showDatePicker = false
    @Environment(\.dismiss) private var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        ZStack {
            // Background
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.theme.primaryText)
                        
                        Text("Sign up to get started")
                            .font(.body)
                            .foregroundColor(.theme.secondaryText)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 32)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Full Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.theme.secondaryText)
                            
                            TextField("Enter your full name", text: $viewModel.fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !viewModel.fullNameError.isEmpty {
                                Text(viewModel.fullNameError)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
                        }
                        
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
                            
                            if !viewModel.emailError.isEmpty {
                                Text(viewModel.emailError)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.theme.secondaryText)
                            
                            SecureField("Create a password", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !viewModel.passwordError.isEmpty {
                                Text(viewModel.passwordError)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.theme.secondaryText)
                            
                            SecureField("Confirm your password", text: $viewModel.confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !viewModel.confirmPasswordError.isEmpty {
                                Text(viewModel.confirmPasswordError)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
                        }
                        
                        // Date of Birth Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of Birth")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.theme.secondaryText)
                            
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack {
                                    Text(dateFormatter.string(from: viewModel.dateOfBirth))
                                        .foregroundColor(.theme.primaryText)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.theme.secondaryText)
                                }
                                .padding()
                                .background(Color.theme.secondaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                            }
                            
                            if !viewModel.dateOfBirthError.isEmpty {
                                Text(viewModel.dateOfBirthError)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
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
                    
                    // Sign Up Button
                    Button(action: {
                        viewModel.signUp()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#234BFF"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || !isFormValid)
                    .opacity((viewModel.isLoading || !isFormValid) ? 0.6 : 1.0)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.theme.secondaryText)
                        
                        Button("Sign In") {
                            navigationCoordinator.navigateToLogin()
                        }
                        .foregroundColor(Color(hex: "#234BFF"))
                        .fontWeight(.medium)
                    }
                    .font(.footnote)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigationCoordinator.navigateToLogin()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.theme.primaryText)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .navigationTitle("Select Date of Birth")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .onChange(of: viewModel.isSignUpSuccessful) { _, isSuccessful in
            if isSuccessful {
                navigationCoordinator.handleSuccessfulSignUp()
            }
        }
    }
    
    private var isFormValid: Bool {
        !viewModel.fullName.isEmpty &&
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        !viewModel.confirmPassword.isEmpty &&
        viewModel.fullNameError.isEmpty &&
        viewModel.emailError.isEmpty &&
        viewModel.passwordError.isEmpty &&
        viewModel.confirmPasswordError.isEmpty &&
        viewModel.dateOfBirthError.isEmpty
    }
}

#Preview {
    SignUpView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthenticationService.shared)
}