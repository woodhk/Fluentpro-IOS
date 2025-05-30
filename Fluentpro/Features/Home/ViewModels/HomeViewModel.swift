import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: Fluentpro.User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showLogoutConfirmation: Bool = false
    @Published var isLoggedOut: Bool = false
    
    // MARK: - User Stats
    @Published var streakDays: Int = 0
    @Published var totalLessonsCompleted: Int = 0
    @Published var currentLevel: String = "Beginner"
    @Published var xpPoints: Int = 0
    
    // MARK: - Private Properties
    private let authenticationService: AuthenticationService
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        authenticationService: AuthenticationService = AuthenticationService.shared,
        userService: UserService = UserService()
    ) {
        self.authenticationService = authenticationService
        self.userService = userService
        
        setupSubscriptions()
        loadUserData()
    }
    
    // MARK: - Public Methods
    func loadUserData() {
        isLoading = true
        errorMessage = ""
        
        Task {
            // Get current user
            if let user = authenticationService.currentUser {
                currentUser = user
                
                // Load user stats
                await loadUserStats()
            }
            isLoading = false
        }
    }
    
    func refreshUserData() {
        loadUserData()
    }
    
    func logout() {
        showLogoutConfirmation = true
    }
    
    func confirmLogout() {
        isLoading = true
        authenticationService.logout()
        clearUserData()
        isLoggedOut = true
        isLoading = false
        showLogoutConfirmation = false
    }
    
    func cancelLogout() {
        showLogoutConfirmation = false
    }
    
    func updateUserProfile(fullName: String? = nil, email: String? = nil) {
        guard currentUser != nil else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            // In a real app, this would call an API to update the user profile
            // For now, we'll just update the local state
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        // Listen for authentication state changes
        authenticationService.$currentUser
            .sink { [weak self] user in
                if user == nil {
                    self?.clearUserData()
                } else {
                    self?.currentUser = user
                }
            }
            .store(in: &cancellables)
        
        // Listen for user updates
        userService.userUpdatesPublisher
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    private func loadUserStats() async {
        // Simulate loading user stats
        // In a real app, this would fetch from a service
        
        // In a real app, this would fetch user stats from a service
        // For now, set some default values
        streakDays = 5
        totalLessonsCompleted = 25
        currentLevel = "Beginner"
        xpPoints = 1250
    }
    
    private func clearUserData() {
        currentUser = nil
        streakDays = 0
        totalLessonsCompleted = 0
        currentLevel = "Beginner"
        xpPoints = 0
        errorMessage = ""
    }
}


// MARK: - Mock Services (Replace with actual implementations)
class UserService {
    let userUpdatesPublisher = PassthroughSubject<Fluentpro.User?, Never>()
    
    func getUser(userId: String) async throws -> Fluentpro.User {
        // Mock implementation
        return Fluentpro.User(
            id: userId,
            fullName: "John Doe",
            email: "john@example.com",
            dateOfBirth: Date()
        )
    }
    
    func updateUser(_ user: Fluentpro.User) async throws -> Fluentpro.User {
        // Mock implementation
        userUpdatesPublisher.send(user)
        return user
    }
}

