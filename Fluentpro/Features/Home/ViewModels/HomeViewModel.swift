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
        // In a real app, this would fetch user stats from the backend
        // For now, initialize with default values since the backend
        // doesn't have user stats endpoints yet
        
        // TODO: Replace with actual API call when backend stats endpoints are available
        // do {
        //     let stats = try await userService.getUserStats()
        //     streakDays = stats.streakDays
        //     totalLessonsCompleted = stats.totalLessonsCompleted
        //     currentLevel = stats.currentLevel
        //     xpPoints = stats.xpPoints
        // } catch {
        //     // Handle error and use defaults
        // }
        
        // Default values for now
        streakDays = 0
        totalLessonsCompleted = 0
        currentLevel = "Beginner"
        xpPoints = 0
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


// MARK: - User Service
class UserService {
    let userUpdatesPublisher = PassthroughSubject<Fluentpro.User?, Never>()
    private let networkService = NetworkService.shared
    
    func getUser(userId: String) async throws -> Fluentpro.User {
        // Get user from backend API
        return try await networkService.get(
            endpoint: .userProfile,
            responseType: Fluentpro.User.self
        )
    }
    
    func updateUser(_ user: Fluentpro.User) async throws -> Fluentpro.User {
        // Update user via backend API
        let updatedUser = try await networkService.put(
            endpoint: .updateProfile,
            body: user,
            responseType: Fluentpro.User.self
        )
        userUpdatesPublisher.send(updatedUser)
        return updatedUser
    }
}

