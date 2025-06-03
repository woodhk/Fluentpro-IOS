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
        case conversationPartners = 4
        case conversationSituations = 5
        case phase2Complete = 6
        case onboardingComplete = 7
        
        var title: String {
            switch self {
                case .welcome: return "Welcome"
                case .intro: return "Getting Started"
                case .basicInfo: return "Phase 1: Role Identification"
                case .phase1Complete: return "Phase 1 Complete"
                case .conversationPartners: return "Phase 2: Communication Context"
                case .conversationSituations: return "Phase 2: Communication Situations"
                case .phase2Complete: return "Phase 2 Complete"
                case .onboardingComplete: return "Onboarding Complete"
            }
        }
        
        var progressValue: Double {
            switch self {
                case .welcome: return 0.0
                case .intro: return 0.1
                case .basicInfo: return 0.3
                case .phase1Complete: return 0.45
                case .conversationPartners: return 0.6
                case .conversationSituations: return 0.75
                case .phase2Complete: return 0.9
                case .onboardingComplete: return 1.0
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
        case matched([Role]) // Now returns multiple roles
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
    @Published var selectedPartners: Set<ConversationPartner> = []
    @Published var currentPartnerSituations: PartnerSituations?
    @Published var allPartnerSituations: [PartnerSituations] = []
    
    // Completion State
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
            return 0.2 + (stepProgress * 0.25) // 20% to 45%
        case .phase1Complete:
            return 0.45
        case .conversationPartners:
            return 0.6
        case .conversationSituations:
            // Progress based on partners completed
            let partnersCount = onboardingData.selectedConversationPartners.count
            let completedCount = onboardingData.partnerSituations.count
            let progress = partnersCount > 0 ? Double(completedCount) / Double(partnersCount) : 0
            return 0.75 + (progress * 0.15) // 75% to 90%
        case .phase2Complete:
            return 0.9
        case .onboardingComplete:
            return 1.0
        }
    }
    
    var currentPhaseLabel: String {
        switch currentPhase {
        case .welcome, .intro:
            return "Getting Started"
        case .basicInfo, .phase1Complete:
            return "Phase 1"
        case .conversationPartners, .conversationSituations, .phase2Complete:
            return "Phase 2"
        case .onboardingComplete:
            return "Complete"
        }
    }
    
    // MARK: - Private Properties
    private let navigationCoordinator = NavigationCoordinator.shared
    private let authService = AuthenticationService.shared
    private let mockService = OnboardingMockService.shared
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
        moveToPhase(.conversationPartners)
    }
    
    func continueFromPhase2Complete() {
        moveToPhase(.onboardingComplete)
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
    
    func selectRole(_ role: Role) {
        onboardingData.selectedRole = role
        onboardingData.didSelectNoMatch = false
        moveToPhase(.phase1Complete)
    }
    
    func selectNoMatch() {
        onboardingData.selectedRole = nil
        onboardingData.didSelectNoMatch = true
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
                
                if !response.roles.isEmpty {
                    onboardingData.matchedRoles = response.roles
                    roleMatchResult = .matched(response.roles)
                } else {
                    onboardingData.matchedRoles = []
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
    func togglePartner(_ partner: ConversationPartner) {
        if selectedPartners.contains(partner) {
            selectedPartners.remove(partner)
            onboardingData.selectedConversationPartners.remove(partner)
            // Remove any existing situations for this partner
            onboardingData.partnerSituations.removeAll { $0.partner == partner }
        } else {
            selectedPartners.insert(partner)
            onboardingData.selectedConversationPartners.insert(partner)
        }
    }
    
    func continueFromPartnerSelection() {
        guard !selectedPartners.isEmpty else {
            errorMessage = "Please select at least one conversation partner"
            return
        }
        
        // Initialize partner situations for selected partners
        onboardingData.partnerSituations = []
        onboardingData.currentPartnerIndex = 0
        
        // Move to situations selection
        moveToPhase(.conversationSituations)
        updateCurrentPartnerSituations()
    }
    
    func toggleSituation(_ situation: ConversationSituation) {
        guard var current = currentPartnerSituations else { return }
        
        if current.situations.contains(situation) {
            current.situations.remove(situation)
        } else {
            current.situations.insert(situation)
        }
        
        currentPartnerSituations = current
    }
    
    func continueFromSituationSelection() {
        guard let current = currentPartnerSituations, !current.situations.isEmpty else {
            errorMessage = "Please select at least one situation"
            return
        }
        
        // Save current partner situations
        if let existingIndex = onboardingData.partnerSituations.firstIndex(where: { $0.partner == current.partner }) {
            onboardingData.partnerSituations[existingIndex] = current
        } else {
            onboardingData.partnerSituations.append(current)
        }
        
        // Move to next partner or complete
        onboardingData.currentPartnerIndex += 1
        
        if onboardingData.currentPartnerIndex < selectedPartners.count {
            updateCurrentPartnerSituations()
        } else {
            // All partners completed
            moveToPhase(.phase2Complete)
        }
    }
    
    private func updateCurrentPartnerSituations() {
        if let currentPartner = onboardingData.currentPartnerForSituations {
            // Check if we already have situations for this partner
            if let existing = onboardingData.partnerSituations.first(where: { $0.partner == currentPartner }) {
                currentPartnerSituations = existing
            } else {
                currentPartnerSituations = PartnerSituations(partner: currentPartner)
            }
        }
    }
    
    func enterFluentpro() {
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

