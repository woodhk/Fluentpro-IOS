import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Date()
    @State private var isLoading = false
    @State private var showDatePicker = false
    
    // Validation errors
    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var dateOfBirthError: String?
    
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
                            
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: fullName) { _, _ in
                                    validateFullName()
                                }
                            
                            if let error = fullNameError {
                                Text(error)
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
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .onChange(of: email) { _, _ in
                                    validateEmail()
                                }
                            
                            if let error = emailError {
                                Text(error)
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
                            
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: password) { _, _ in
                                    validatePassword()
                                    validateConfirmPassword()
                                }
                            
                            if let error = passwordError {
                                Text(error)
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
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: confirmPassword) { _, _ in
                                    validateConfirmPassword()
                                }
                            
                            if let error = confirmPasswordError {
                                Text(error)
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
                                    Text(dateFormatter.string(from: dateOfBirth))
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
                            
                            if let error = dateOfBirthError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.theme.error)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Button
                    Button(action: handleSignUp) {
                        HStack {
                            if isLoading {
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
                    .disabled(isLoading || !isFormValid)
                    .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.theme.secondaryText)
                        
                        Button("Sign In") {
                            dismiss()
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
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.theme.primaryText)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .navigationTitle("Select Date of Birth")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                validateDateOfBirth()
                                showDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        fullNameError == nil &&
        emailError == nil &&
        passwordError == nil &&
        confirmPasswordError == nil &&
        dateOfBirthError == nil
    }
    
    private func validateFullName() {
        if fullName.isEmpty {
            fullNameError = "Full name is required"
        } else if fullName.count < 2 {
            fullNameError = "Full name must be at least 2 characters"
        } else {
            fullNameError = nil
        }
    }
    
    private func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required"
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Please enter a valid email address"
        } else {
            emailError = nil
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
        } else {
            passwordError = nil
        }
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = nil
        }
    }
    
    private func validateDateOfBirth() {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        
        if let age = ageComponents.year, age < 13 {
            dateOfBirthError = "You must be at least 13 years old"
        } else {
            dateOfBirthError = nil
        }
    }
    
    private func handleSignUp() {
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Validate all fields
        validateFullName()
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        validateDateOfBirth()
        
        guard isFormValid else { return }
        
        isLoading = true
        
        // Simulate sign up - Replace with actual authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            // Handle sign up success/failure
            // For now, just dismiss
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}