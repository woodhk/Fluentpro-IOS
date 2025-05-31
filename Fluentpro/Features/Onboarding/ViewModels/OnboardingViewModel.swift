import Foundation
import Combine
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Onboarding Phases
    enum OnboardingPhase: Int, CaseIterable {
        case basicInfo = 1
        case aiConversation = 2
        case courseSelection = 3
        
        var title: String {
            switch self {
                case .basicInfo: return "Basic Information"
                case .aiConversation: return "Let's Chat"
                case .courseSelection: return "Your Courses"
            }
        }
        
        var phaseNumber: String {
            return "\(rawValue)/3"
        }
    }
    
    enum BasicInfoStep: Int, CaseIterable {
        case language = 0
        case industry = 1
        case role = 2
        case roleConfirmation = 3
    }
    
    // MARK: - Published Properties
    @Published var currentPhase: OnboardingPhase = .basicInfo
    @Published var currentBasicInfoStep: BasicInfoStep = .language
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isOnboardingComplete: Bool = false
    @Published var showIntermission: Bool = false
    
    // Onboarding Data
    @Published var onboardingData = OnboardingData()
    
    // Phase 1 State
    @Published var showRoleConfirmation: Bool = false
    @Published var roleSearchInProgress: Bool = false
    
    // Phase 2 State
    @Published var conversationMessages: [AIConversationMessage] = []
    @Published var userMessageText: String = ""
    @Published var isAITyping: Bool = false
    @Published var showContinueButton: Bool = false
    
    // Phase 3 State
    @Published var coursesLoading: Bool = false
    @Published var showCompletionScreen: Bool = false
    
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
    
    func confirmRole(_ confirmed: Bool) {
        if confirmed {
            // User confirmed the matched role
            moveToPhase(.aiConversation)
        } else {
            // User rejected the match, continue with custom role
            onboardingData.matchedRole = nil
            moveToPhase(.aiConversation)
        }
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
                    showRoleConfirmation = true
                    currentBasicInfoStep = .roleConfirmation
                } else {
                    // No match found, proceed to AI conversation
                    onboardingData.matchedRole = nil
                    moveToPhase(.aiConversation)
                }
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
            showRoleConfirmation = false
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
                
                // Check if we should show continue button
                showContinueButton = aiService.shouldShowContinueButton(messageCount: conversationMessages.count)
            } catch {
                errorMessage = "Failed to get AI response"
            }
            isAITyping = false
        }
    }
    
    func continueFromConversation() {
        // Extract needs from conversation
        onboardingData.identifiedNeeds = aiService.extractNeeds(from: conversationMessages)
        
        // Show intermission and load courses
        showIntermission = true
        loadCourses()
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
        case .roleConfirmation:
            return true
        }
    }
    
    // MARK: - Private Methods
    private func setupSubscriptions() {
        // Any Combine subscriptions needed
    }
}

