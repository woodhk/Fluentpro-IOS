import Foundation
import Combine
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Onboarding Phases
    enum OnboardingPhase: Int, CaseIterable {
        case welcome = 0
        case intro = 1
        case basicInfo = 2
        case phase1Complete = 3
        case aiConversation = 4
        case phase2Complete = 5
        case courseSelection = 6
        
        var title: String {
            switch self {
                case .welcome: return "Welcome"
                case .intro: return "Getting Started"
                case .basicInfo: return "Phase 1: Role Identification"
                case .phase1Complete: return "Phase 1 Complete"
                case .aiConversation: return "Phase 2: AI Consultation"
                case .phase2Complete: return "Phase 2 Complete"
                case .courseSelection: return "Phase 3: Course Selection"
            }
        }
        
        var progressValue: Double {
            switch self {
                case .welcome: return 0.0
                case .intro: return 0.1
                case .basicInfo: return 0.3
                case .phase1Complete: return 0.45
                case .aiConversation: return 0.65
                case .phase2Complete: return 0.8
                case .courseSelection: return 1.0
            }
        }
    }
    
    enum BasicInfoStep: Int, CaseIterable {
        case language = 0
        case industry = 1
        case role = 2
        case roleResult = 3
    }
    
    enum RoleMatchResult {
        case matched(Role)
        case notMatched
    }
    
    // MARK: - Published Properties
    @Published var currentPhase: OnboardingPhase = .welcome
    @Published var currentBasicInfoStep: BasicInfoStep = .language
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isOnboardingComplete: Bool = false
    @Published var showIntermission: Bool = false
    
    // Onboarding Data
    @Published var onboardingData = OnboardingData()
    
    // Phase 1 State
    @Published var roleMatchResult: RoleMatchResult?
    @Published var roleSearchInProgress: Bool = false
    
    // Phase 2 State
    @Published var conversationMessages: [AIConversationMessage] = []
    @Published var userMessageText: String = ""
    @Published var isAITyping: Bool = false
    @Published var conversationComplete: Bool = false
    
    // Phase 3 State
    @Published var coursesLoading: Bool = false
    @Published var showCompletionScreen: Bool = false
    
    // MARK: - Computed Properties
    var screenProgress: Double {
        switch currentPhase {
        case .welcome:
            return 0.0
        case .intro:
            return 0.1
        case .basicInfo:
            // Progress within Phase 1 based on current step
            let stepProgress = Double(currentBasicInfoStep.rawValue) / Double(BasicInfoStep.allCases.count - 1)
            return 0.2 + (stepProgress * 0.4) // 20% to 60%
        case .phase1Complete:
            return 0.6
        case .aiConversation:
            // Progress within Phase 2 based on conversation completion
            return conversationComplete ? 0.9 : 0.7
        case .phase2Complete:
            return 0.95
        case .courseSelection:
            return 1.0
        }
    }
    
    var currentPhaseLabel: String {
        switch currentPhase {
        case .welcome, .intro:
            return "Getting Started"
        case .basicInfo, .phase1Complete:
            return "Phase 1"
        case .aiConversation, .phase2Complete:
            return "Phase 2"
        case .courseSelection:
            return "Phase 3"
        }
    }
    
    // MARK: - Private Properties
    private let navigationCoordinator = NavigationCoordinator.shared
    private let authService = AuthenticationService.shared
    private let mockService = OnboardingMockService.shared
    private let aiService = AIConversationService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupSubscriptions()
    }
    
    // MARK: - Welcome/Intro Methods
    func continueFromWelcome() {
        moveToPhase(.intro)
    }
    
    func continueFromIntro() {
        moveToPhase(.basicInfo)
    }
    
    func continueFromPhase1Complete() {
        moveToPhase(.aiConversation)
    }
    
    func continueFromPhase2Complete() {
        // Show intermission and load courses
        showIntermission = true
        loadCourses()
    }
    
    // MARK: - Phase 1 Methods
    func selectLanguage(_ language: Language) {
        onboardingData.nativeLanguage = language
        nextBasicInfoStep()
    }
    
    func selectIndustry(_ industry: Industry) {
        onboardingData.industry = industry
        nextBasicInfoStep()
    }
    
    func submitRole() {
        guard !onboardingData.roleTitle.isEmpty && !onboardingData.roleDescription.isEmpty else {
            errorMessage = "Please provide both role title and description"
            return
        }
        
        searchForMatchingRole()
    }
    
    func continueFromRoleResult() {
        moveToPhase(.phase1Complete)
    }
    
    private func searchForMatchingRole() {
        roleSearchInProgress = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await mockService.matchRole(
                    title: onboardingData.roleTitle,
                    description: onboardingData.roleDescription,
                    industry: onboardingData.industry?.rawValue ?? ""
                )
                
                if response.matched, let role = response.role {
                    onboardingData.matchedRole = role
                    roleMatchResult = .matched(role)
                } else {
                    onboardingData.matchedRole = nil
                    roleMatchResult = .notMatched
                }
                currentBasicInfoStep = .roleResult
            } catch {
                errorMessage = "Error searching for role: \(error.localizedDescription)"
            }
            roleSearchInProgress = false
        }
    }
    
    private func nextBasicInfoStep() {
        if let nextStep = BasicInfoStep(rawValue: currentBasicInfoStep.rawValue + 1) {
            currentBasicInfoStep = nextStep
        }
    }
    
    func previousBasicInfoStep() {
        if let previousStep = BasicInfoStep(rawValue: currentBasicInfoStep.rawValue - 1) {
            currentBasicInfoStep = previousStep
            roleMatchResult = nil
        }
    }
    
    // MARK: - Phase 2 Methods
    func sendMessage() {
        guard !userMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = AIConversationMessage(content: userMessageText, isUser: true)
        conversationMessages.append(userMessage)
        onboardingData.conversationMessages = conversationMessages
        
        let messageText = userMessageText
        userMessageText = ""
        isAITyping = true
        
        Task {
            do {
                let aiResponse = try await aiService.processUserMessage(messageText, context: onboardingData)
                let aiMessage = AIConversationMessage(content: aiResponse, isUser: false)
                conversationMessages.append(aiMessage)
                onboardingData.conversationMessages = conversationMessages
                
                // Check if conversation is complete
                if aiService.shouldShowContinueButton(messageCount: conversationMessages.count) {
                    conversationComplete = true
                }
            } catch {
                errorMessage = "Failed to get AI response"
            }
            isAITyping = false
        }
    }
    
    func finishConversation() {
        // Extract needs from conversation
        onboardingData.identifiedNeeds = aiService.extractNeeds(from: conversationMessages)
        
        // Move to Phase 2 complete
        moveToPhase(.phase2Complete)
    }
    
    // MARK: - Phase 3 Methods
    private func loadCourses() {
        Task {
            // Simulate loading time
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            do {
                let response = try await mockService.recommendCourses(
                    for: onboardingData.matchedRole?.id,
                    industry: onboardingData.industry?.rawValue ?? "",
                    needs: onboardingData.identifiedNeeds
                )
                
                onboardingData.availableCourses = response.courses
                showIntermission = false
                moveToPhase(.courseSelection)
            } catch {
                errorMessage = "Failed to load courses"
                showIntermission = false
            }
        }
    }
    
    func selectCourse(_ course: Course) {
        onboardingData.selectedCourse = course
        completeOnboarding()
    }
    
    func acknowledgeNoCourses() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        showCompletionScreen = true
    }
    
    func finishOnboarding() {
        // Save onboarding data (would normally persist to backend)
        isOnboardingComplete = true
        navigationCoordinator.navigateToHome()
    }
    
    // MARK: - Navigation
    private func moveToPhase(_ phase: OnboardingPhase) {
        withAnimation {
            currentPhase = phase
        }
    }
    
    func canProceedInBasicInfo() -> Bool {
        switch currentBasicInfoStep {
        case .language:
            return onboardingData.nativeLanguage != nil
        case .industry:
            return onboardingData.industry != nil
        case .role:
            return !onboardingData.roleTitle.isEmpty && !onboardingData.roleDescription.isEmpty
        case .roleResult:
            return true
        }
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        // Any Combine subscriptions needed
    }
}

