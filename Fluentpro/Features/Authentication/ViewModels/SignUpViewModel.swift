import Foundation
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isSignUpSuccessful: Bool = false
    
    // MARK: - Validation Error Messages
    @Published var fullNameError: String = ""
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var confirmPasswordError: String = ""
    @Published var dateOfBirthError: String = ""
    
    // MARK: - Private Properties
    private let authenticationService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    
    // Minimum age requirement (e.g., 13 years old)
    private let minimumAge = 13
    
    // MARK: - Initialization
    init(authenticationService: AuthenticationService = AuthenticationService.shared) {
        self.authenticationService = authenticationService
        setupValidation()
    }
    
    // MARK: - Public Methods
    func signUp() {
        // Clear general error message
        errorMessage = ""
        
        // Validate all fields
        guard validateForm() else { return }
        
        // Start loading
        isLoading = true
        
        // Perform sign up
        Task {
            do {
                _ = try await authenticationService.signUp(
                    fullName: fullName,
                    email: email,
                    password: password,
                    dateOfBirth: dateOfBirth
                )
                isSignUpSuccessful = true
                clearForm()
            } catch {
                errorMessage = handleError(error)
            }
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func setupValidation() {
        // Real-time validation for full name
        $fullName
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateFullName(value)
            }
            .store(in: &cancellables)
        
        // Real-time validation for email
        $email
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateEmail(value)
            }
            .store(in: &cancellables)
        
        // Real-time validation for password
        $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validatePassword(value)
            }
            .store(in: &cancellables)
        
        // Real-time validation for confirm password
        Publishers.CombineLatest($password, $confirmPassword)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] password, confirmPassword in
                self?.validateConfirmPassword(password: password, confirmPassword: confirmPassword)
            }
            .store(in: &cancellables)
        
        // Real-time validation for date of birth
        $dateOfBirth
            .sink { [weak self] value in
                self?.validateDateOfBirth(value)
            }
            .store(in: &cancellables)
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        
        // Validate full name
        if !validateFullName(fullName) {
            isValid = false
        }
        
        // Validate email
        if !validateEmail(email) {
            isValid = false
        }
        
        // Validate password
        if !validatePassword(password) {
            isValid = false
        }
        
        // Validate confirm password
        if !validateConfirmPassword(password: password, confirmPassword: confirmPassword) {
            isValid = false
        }
        
        // Validate date of birth
        if !validateDateOfBirth(dateOfBirth) {
            isValid = false
        }
        
        return isValid
    }
    
    @discardableResult
    private func validateFullName(_ name: String) -> Bool {
        if name.isEmpty {
            fullNameError = "Full name is required"
            return false
        }
        
        if name.count < 2 {
            fullNameError = "Full name must be at least 2 characters"
            return false
        }
        
        if name.count > 50 {
            fullNameError = "Full name must be less than 50 characters"
            return false
        }
        
        // Check for valid characters (letters and spaces only)
        let nameRegex = "^[a-zA-Z ]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !namePredicate.evaluate(with: name) {
            fullNameError = "Full name can only contain letters and spaces"
            return false
        }
        
        fullNameError = ""
        return true
    }
    
    @discardableResult
    private func validateEmail(_ email: String) -> Bool {
        if email.isEmpty {
            emailError = "Email is required"
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
            return false
        }
        
        emailError = ""
        return true
    }
    
    @discardableResult
    private func validatePassword(_ password: String) -> Bool {
        if password.isEmpty {
            passwordError = "Password is required"
            return false
        }
        
        if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
            return false
        }
        
        // Check for at least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) {
            passwordError = "Password must contain at least one uppercase letter"
            return false
        }
        
        // Check for at least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) {
            passwordError = "Password must contain at least one lowercase letter"
            return false
        }
        
        // Check for at least one number
        let numberRegex = ".*[0-9]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) {
            passwordError = "Password must contain at least one number"
            return false
        }
        
        // Check for at least one special character
        let specialCharRegex = ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) {
            passwordError = "Password must contain at least one special character"
            return false
        }
        
        passwordError = ""
        return true
    }
    
    @discardableResult
    private func validateConfirmPassword(password: String, confirmPassword: String) -> Bool {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
            return false
        }
        
        if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
            return false
        }
        
        confirmPasswordError = ""
        return true
    }
    
    @discardableResult
    private func validateDateOfBirth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        
        guard let age = ageComponents.year else {
            dateOfBirthError = "Invalid date of birth"
            return false
        }
        
        if age < minimumAge {
            dateOfBirthError = "You must be at least \(minimumAge) years old"
            return false
        }
        
        if age > 150 {
            dateOfBirthError = "Please enter a valid date of birth"
            return false
        }
        
        dateOfBirthError = ""
        return true
    }
    
    private func handleError(_ error: Error) -> String {
        // Handle specific authentication errors
        if let authError = error as? AuthenticationError {
            return authError.localizedDescription
        }
        
        // Generic error handling
        return error.localizedDescription
    }
    
    private func clearForm() {
        fullName = ""
        email = ""
        password = ""
        confirmPassword = ""
        dateOfBirth = Date()
        errorMessage = ""
        fullNameError = ""
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
        dateOfBirthError = ""
    }
}