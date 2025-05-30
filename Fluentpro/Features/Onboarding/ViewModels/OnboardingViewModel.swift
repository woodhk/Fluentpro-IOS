import Foundation
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Onboarding Steps
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case languageSelection
        case proficiencyLevel
        case learningGoals
        case dailyGoal
        case notifications
        case completion
        
        var title: String {
            switch self {
            case .welcome:
                return "Welcome to FluentPro"
            case .languageSelection:
                return "Choose Your Language"
            case .proficiencyLevel:
                return "What's Your Level?"
            case .learningGoals:
                return "Set Your Goals"
            case .dailyGoal:
                return "Daily Practice Goal"
            case .notifications:
                return "Stay on Track"
            case .completion:
                return "You're All Set!"
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return "Start your journey to language mastery"
            case .languageSelection:
                return "Select the language you want to learn"
            case .proficiencyLevel:
                return "Help us personalize your learning experience"
            case .learningGoals:
                return "What would you like to achieve?"
            case .dailyGoal:
                return "How much time can you practice daily?"
            case .notifications:
                return "Get reminders to keep your streak alive"
            case .completion:
                return "Ready to begin your learning adventure!"
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isOnboardingComplete: Bool = false
    
    // User selections
    @Published var selectedLanguage: Language?
    @Published var selectedProficiencyLevel: ProficiencyLevel?
    @Published var selectedGoals: Set<LearningGoal> = []
    @Published var dailyGoalMinutes: Int = 15
    @Published var notificationsEnabled: Bool = true
    @Published var preferredNotificationTime: Date = Date()
    
    // UI State
    @Published var canProceed: Bool = false
    @Published var showSkipButton: Bool = false
    
    // MARK: - Private Properties
    private let userPreferencesService: UserPreferencesService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(userPreferencesService: UserPreferencesService = UserPreferencesService()) {
        self.userPreferencesService = userPreferencesService
        setupValidation()
    }
    
    // MARK: - Public Methods
    func nextStep() {
        guard canProceed else { return }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
            updateStepValidation()
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
            updateStepValidation()
        }
    }
    
    func skipStep() {
        guard showSkipButton else { return }
        nextStep()
    }
    
    func selectLanguage(_ language: Language) {
        selectedLanguage = language
    }
    
    func selectProficiencyLevel(_ level: ProficiencyLevel) {
        selectedProficiencyLevel = level
    }
    
    func toggleGoal(_ goal: LearningGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }
    
    func setDailyGoal(_ minutes: Int) {
        dailyGoalMinutes = minutes
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
    
    func completeOnboarding() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Save user preferences
                let preferences = UserPreferences(
                    selectedLanguage: selectedLanguage!,
                    proficiencyLevel: selectedProficiencyLevel!,
                    learningGoals: Array(selectedGoals),
                    dailyGoalMinutes: dailyGoalMinutes,
                    notificationsEnabled: notificationsEnabled,
                    preferredNotificationTime: preferredNotificationTime
                )
                
                try await userPreferencesService.savePreferences(preferences)
                
                // Request notification permissions if enabled
                if notificationsEnabled {
                    await requestNotificationPermissions()
                }
                
                isOnboardingComplete = true
            } catch {
                errorMessage = "Failed to save preferences: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func setupValidation() {
        // Combine publishers to validate current step
        Publishers.CombineLatest4(
            $currentStep,
            $selectedLanguage,
            $selectedProficiencyLevel,
            $selectedGoals
        )
        .sink { [weak self] step, language, level, goals in
            self?.validateCurrentStep(step: step, language: language, level: level, goals: goals)
        }
        .store(in: &cancellables)
    }
    
    private func validateCurrentStep(
        step: OnboardingStep,
        language: Language?,
        level: ProficiencyLevel?,
        goals: Set<LearningGoal>
    ) {
        switch step {
        case .welcome:
            canProceed = true
            showSkipButton = false
        case .languageSelection:
            canProceed = language != nil
            showSkipButton = false
        case .proficiencyLevel:
            canProceed = level != nil
            showSkipButton = false
        case .learningGoals:
            canProceed = !goals.isEmpty
            showSkipButton = true
        case .dailyGoal:
            canProceed = true
            showSkipButton = true
        case .notifications:
            canProceed = true
            showSkipButton = true
        case .completion:
            canProceed = true
            showSkipButton = false
        }
    }
    
    private func updateStepValidation() {
        validateCurrentStep(
            step: currentStep,
            language: selectedLanguage,
            level: selectedProficiencyLevel,
            goals: selectedGoals
        )
    }
    
    private func requestNotificationPermissions() async {
        // Implementation would request notification permissions
        // This is a placeholder for the actual implementation
    }
}

// MARK: - Supporting Types
enum Language: String, CaseIterable, Identifiable, Codable {
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    case italian = "Italian"
    case portuguese = "Portuguese"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case korean = "Korean"
    
    var id: String { rawValue }
    
    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        }
    }
}

enum ProficiencyLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case native = "Native"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .beginner:
            return "I'm new to this language"
        case .elementary:
            return "I know some basic words and phrases"
        case .intermediate:
            return "I can have simple conversations"
        case .advanced:
            return "I'm comfortable with most situations"
        case .native:
            return "I'm a native speaker"
        }
    }
}

enum LearningGoal: String, CaseIterable, Identifiable, Codable, Hashable {
    case travel = "Travel"
    case business = "Business"
    case culture = "Culture"
    case family = "Family & Friends"
    case education = "Education"
    case career = "Career Growth"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .travel: return "✈️"
        case .business: return "💼"
        case .culture: return "🎭"
        case .family: return "👨‍👩‍👧‍👦"
        case .education: return "🎓"
        case .career: return "📈"
        }
    }
}

// MARK: - User Preferences Model
struct UserPreferences: Codable {
    let selectedLanguage: Language
    let proficiencyLevel: ProficiencyLevel
    let learningGoals: [LearningGoal]
    let dailyGoalMinutes: Int
    let notificationsEnabled: Bool
    let preferredNotificationTime: Date
}

// MARK: - Mock Service
class UserPreferencesService {
    func savePreferences(_ preferences: UserPreferences) async throws {
        // Mock implementation
        // In a real app, this would save to UserDefaults or a backend service
    }
}

