import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var promptSignUp: Bool = false
    
    // MARK: - Private Properties
    private let authenticationService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authenticationService: AuthenticationService = AuthenticationService.shared) {
        self.authenticationService = authenticationService
    }
    
    // MARK: - Public Methods
    func login() {
        // Clear previous error message
        errorMessage = ""
        
        // Validate input
        guard validateInput() else { return }
        
        // Start loading
        isLoading = true
        
        // Perform login
        Task {
            do {
                let user = try await authenticationService.login(email: email, password: password)
                print("🎉 Login successful for user: \(user.email)")
                await MainActor.run {
                    print("🔄 Setting isLoggedIn = true")
                    isLoggedIn = true
                    clearForm()
                }
            } catch {
                print("❌ Login failed: \(error)")
                await MainActor.run {
                    errorMessage = handleError(error)
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    // MARK: - Private Methods
    private func validateInput() -> Bool {
        // Email validation
        if email.isEmpty {
            errorMessage = "Please enter your email"
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Password validation
        if password.isEmpty {
            errorMessage = "Please enter your password"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleError(_ error: Error) -> String {
        // Handle specific authentication errors
        if let authError = error as? AuthenticationError {
            switch authError {
            case .userNotFound:
                // Set a flag to prompt sign up
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.promptSignUp = true
                }
            default:
                break
            }
            return authError.localizedDescription
        }
        
        // Generic error handling
        return error.localizedDescription
    }
    
    private func clearForm() {
        email = ""
        password = ""
        errorMessage = ""
    }
}

