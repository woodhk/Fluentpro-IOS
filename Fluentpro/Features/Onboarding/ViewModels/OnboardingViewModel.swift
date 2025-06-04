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
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupSubscriptions()
        // Set initial phase based on user's onboarding status
        Task {
            await setInitialPhaseFromBackend()
        }
    }
    
    // MARK: - Welcome/Intro Methods
    func continueFromWelcome() {
        moveToPhase(.intro)
    }
    
    func continueFromIntro() {
        moveToPhase(.basicInfo)
        // Load industries when entering basic info phase
        Task {
            await loadIndustries()
        }
    }
    
    func continueFromPhase1Complete() {
        moveToPhase(.conversationPartners)
    }
    
    func continueFromPhase2Complete() {
        moveToPhase(.onboardingComplete)
    }
    
    // MARK: - Phase 1 Methods
    func selectLanguage(_ language: Language) {
        print("🎯 [ONBOARDING] Language selected: \(language.displayName) (sending: \(language.rawValue))")
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let request = SetLanguageRequest(nativeLanguage: language.rawValue)
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .setLanguage,
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Language saved successfully")
                onboardingData.nativeLanguage = language
                nextBasicInfoStep()
            } catch {
                print("❌ [ONBOARDING] Failed to save language: \(error)")
                errorMessage = "Failed to save language selection: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // MARK: - Industry Management
    @Published var availableIndustries: [APIIndustry] = []
    
    func loadIndustries() async {
        print("🏭 [ONBOARDING] Loading industries from backend...")
        
        do {
            let response: IndustriesResponse = try await networkService.get(
                endpoint: .getIndustries,
                responseType: IndustriesResponse.self
            )
            
            await MainActor.run {
                self.availableIndustries = response.industries
            }
            print("✅ [ONBOARDING] Loaded \(response.industries.count) industries from backend:")
            for industry in response.industries {
                print("   - \(industry.name) (ID: \(industry.id))")
            }
        } catch {
            print("❌ [ONBOARDING] Failed to load industries from backend: \(error)")
            print("🔄 [ONBOARDING] Using fallback default industries")
            // Fall back to default industries if backend fails
            await MainActor.run {
                self.availableIndustries = createDefaultIndustries()
                print("📝 [ONBOARDING] Created \(self.availableIndustries.count) fallback industries:")
                for industry in self.availableIndustries {
                    print("   - \(industry.name) (ID: \(industry.id))")
                }
            }
        }
    }
    
    private func createDefaultIndustries() -> [APIIndustry] {
        return [
            APIIndustry(id: UUID().uuidString, name: "Banking & Finance", description: "Financial services and banking", isActive: true, sortOrder: 1),
            APIIndustry(id: UUID().uuidString, name: "Shipping & Logistics", description: "Transportation and logistics", isActive: true, sortOrder: 2),
            APIIndustry(id: UUID().uuidString, name: "Real Estate", description: "Property and real estate", isActive: true, sortOrder: 3),
            APIIndustry(id: UUID().uuidString, name: "Hotels & Hospitality", description: "Hospitality and tourism", isActive: true, sortOrder: 4)
        ]
    }
    
    func selectIndustry(_ industry: Industry) {
        print("🎯 [ONBOARDING] Industry selected: \(industry.rawValue)")
        
        // Send the industry name directly to the backend
        print("🎯 [ONBOARDING] Sending industry name: \(industry.rawValue)")
        saveIndustryWithName(industry.rawValue, industry: industry)
    }
    
    private func getHardcodedIndustryId(_ industry: Industry) -> String {
        // These might need to be updated to match actual UUIDs in the backend database
        // This is a temporary solution until the backend industries endpoint is available
        switch industry {
        case .bankingFinance:
            return "11111111-1111-1111-1111-111111111111" // Banking & Finance
        case .shippingLogistics:
            return "22222222-2222-2222-2222-222222222222" // Shipping & Logistics
        case .realEstate:
            return "33333333-3333-3333-3333-333333333333" // Real Estate
        case .hotelsHospitality:
            return "44444444-4444-4444-4444-444444444444" // Hotels & Hospitality
        }
    }
    
    private func saveIndustryWithName(_ industryName: String, industry: Industry) {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let request = SetIndustryRequest(industryName: industryName)
                
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .setIndustry,
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Industry saved successfully")
                onboardingData.industry = industry
                nextBasicInfoStep()
            } catch {
                print("❌ [ONBOARDING] Failed to save industry: \(error)")
                errorMessage = "Failed to save industry selection: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func submitRole() {
        guard !onboardingData.roleTitle.isEmpty && !onboardingData.roleDescription.isEmpty else {
            errorMessage = "Please provide both role title and description"
            return
        }
        
        searchForMatchingRole()
    }
    
    func selectRole(_ role: Role) {
        print("🎯 [ONBOARDING] Role selected: \(role.title)")
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let request = RoleSelectionRequest(roleId: role.id)
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .roleSelection(roleId: role.id),
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Role selection saved successfully")
                onboardingData.selectedRole = role
                onboardingData.didSelectNoMatch = false
                moveToPhase(.phase1Complete)
            } catch {
                print("❌ [ONBOARDING] Failed to save role selection: \(error)")
                errorMessage = "Failed to save role selection: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func selectNoMatch() {
        print("🎯 [ONBOARDING] User selected no match - creating custom role")
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let request = CreateCustomRoleRequest(
                    jobTitle: onboardingData.roleTitle,
                    jobDescription: onboardingData.roleDescription,
                    hierarchyLevel: "associate" // Default level
                )
                
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .createCustomRole,
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Custom role created successfully")
                onboardingData.selectedRole = nil
                onboardingData.didSelectNoMatch = true
                moveToPhase(.phase1Complete)
            } catch {
                print("❌ [ONBOARDING] Failed to create custom role: \(error)")
                errorMessage = "Failed to create custom role: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func searchForMatchingRole() {
        roleSearchInProgress = true
        errorMessage = ""
        
        print("🎯 [ONBOARDING] Searching for role matches")
        print("🎯 [ONBOARDING] Job title: \(onboardingData.roleTitle)")
        print("🎯 [ONBOARDING] Job description: \(onboardingData.roleDescription)")
        
        Task {
            do {
                let request = JobInputRequest(
                    jobTitle: onboardingData.roleTitle,
                    jobDescription: onboardingData.roleDescription
                )
                
                let response: RoleMatchResponse = try await networkService.post(
                    endpoint: .jobInput,
                    body: request,
                    responseType: RoleMatchResponse.self
                )
                
                print("🎯 [ONBOARDING] API Response: \(response.totalMatches) matches found")
                
                if !response.matchedRoles.isEmpty {
                    // Convert API roles to local Role model
                    let roles = response.matchedRoles.map { match in
                        Role(
                            id: match.id,
                            title: match.title,
                            description: match.description,
                            industry: match.industryName,
                            commonTasks: [],
                            confidence: match.relevanceScore
                        )
                    }
                    onboardingData.matchedRoles = roles
                    roleMatchResult = .matched(roles)
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
        
        print("🎯 [ONBOARDING] Saving partner selections: \(selectedPartners.map { $0.rawValue })")
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Map ConversationPartner enum to simple partner ID array for backend
                let partnerIds = selectedPartners.map { mapPartnerToId($0) }
                
                // Create simple request struct to match backend expectation
                let request = SimplePartnerSelectionRequest(partnerIds: partnerIds)
                
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .selectCommunicationPartners,
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Partner selections saved successfully")
                
                // Initialize partner situations for selected partners
                onboardingData.partnerSituations = []
                onboardingData.currentPartnerIndex = 0
                
                // Move to situations selection
                moveToPhase(.conversationSituations)
                updateCurrentPartnerSituations()
            } catch {
                print("❌ [ONBOARDING] Failed to save partner selections: \(error)")
                errorMessage = "Failed to save partner selections: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func mapPartnerToId(_ partner: ConversationPartner) -> String {
        // Map enum to backend IDs - this would normally come from fetching partners
        switch partner {
        case .clients:
            return "clients"
        case .customers:
            return "customers"
        case .colleagues:
            return "colleagues"
        case .suppliers:
            return "suppliers"
        case .partners:
            return "partners"
        case .seniorManagement:
            return "senior-management"
        case .stakeholders:
            return "stakeholders"
        case .other:
            return "other"
        }
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
        
        print("🎯 [ONBOARDING] Saving situations for partner: \(current.partner.rawValue)")
        print("🎯 [ONBOARDING] Selected situations: \(current.situations.map { $0.rawValue })")
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Map ConversationSituation enum to API format
                let unitSelections = current.situations.enumerated().map { index, situation in
                    UnitSelection(
                        unitId: mapSituationToId(situation),
                        priority: index + 1
                    )
                }
                
                let request = SelectUnitsRequest(unitSelections: unitSelections)
                let partnerId = mapPartnerToId(current.partner)
                
                let _: EmptyOnboardingResponse = try await networkService.post(
                    endpoint: .selectPartnerUnits(partnerId: partnerId),
                    body: request,
                    responseType: EmptyOnboardingResponse.self
                )
                
                print("✅ [ONBOARDING] Partner situations saved successfully")
                
                // Save current partner situations locally
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
            } catch {
                print("❌ [ONBOARDING] Failed to save partner situations: \(error)")
                errorMessage = "Failed to save situations: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func mapSituationToId(_ situation: ConversationSituation) -> String {
        // Map enum to backend IDs
        switch situation {
        case .interviews:
            return "interviews"
        case .conflictResolution:
            return "conflict-resolution"
        case .phoneCalls:
            return "phone-calls"
        case .oneOnOnes:
            return "one-on-ones"
        case .feedbackSessions:
            return "feedback-sessions"
        case .teamDiscussions:
            return "team-discussions"
        case .negotiations:
            return "negotiations"
        case .statusUpdates:
            return "status-updates"
        case .informalChats:
            return "informal-chats"
        case .briefings:
            return "briefings"
        case .meetings:
            return "meetings"
        case .presentations:
            return "presentations"
        case .trainingSessions:
            return "training-sessions"
        case .clientConversations:
            return "client-conversations"
        case .videoConferences:
            return "video-conferences"
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
    
    private func setInitialPhaseFromBackend() async {
        do {
            let profile = try await authService.getUserProfile()
            print("📊 [ONBOARDING] User onboarding status from backend: \(profile.onboardingStatus)")
            
            await MainActor.run {
                switch profile.onboardingStatus {
                case "pending", "welcome":
                    currentPhase = .welcome
                case "basic_info":
                    currentPhase = .basicInfo
                    // Load industries if going to basic info
                    Task {
                        await loadIndustries()
                    }
                case "personalisation":
                    // User has completed Phase 1, should be in Phase 2 (partner selection)
                    currentPhase = .conversationPartners
                    print("🎯 [ONBOARDING] User in personalisation phase - starting Phase 2 partner selection")
                case "course_assignment":
                    // User has selected partners, should be in situations selection
                    currentPhase = .conversationSituations
                    print("🎯 [ONBOARDING] User in course_assignment phase - starting situations selection")
                case "completed":
                    // Should not reach here as navigation would go to home
                    currentPhase = .onboardingComplete
                default:
                    // Default to welcome for unknown statuses
                    currentPhase = .welcome
                    print("❓ [ONBOARDING] Unknown status '\(profile.onboardingStatus)' - defaulting to welcome")
                }
                print("✅ [ONBOARDING] Initial phase set to: \(currentPhase)")
            }
        } catch {
            print("❌ [ONBOARDING] Failed to get user profile for phase initialization: \(error)")
            // Default to welcome phase if we can't get backend status
            await MainActor.run {
                currentPhase = .welcome
            }
        }
    }
}

