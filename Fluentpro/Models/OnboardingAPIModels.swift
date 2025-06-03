import Foundation

// MARK: - Phase 1: Language & Industry

// Language
struct SetLanguageRequest: Codable {
    let nativeLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case nativeLanguage = "native_language"
    }
}

struct LanguageOption: Codable {
    let value: String
    let label: String
}

struct LanguagesResponse: Codable {
    let languages: [LanguageOption]
}

// Industry
struct SetIndustryRequest: Codable {
    let industryName: String
    
    enum CodingKeys: String, CodingKey {
        case industryName = "industry_name"
    }
}

struct APIIndustry: Codable {
    let id: String
    let name: String
    let description: String?
    let isActive: Bool
    let sortOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isActive = "is_active"
        case sortOrder = "sort_order"
    }
}

struct IndustriesResponse: Codable {
    let industries: [APIIndustry]
}

// MARK: - Role Management

struct JobInputRequest: Codable {
    let jobTitle: String
    let jobDescription: String
    
    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case jobDescription = "job_description"
    }
}

struct APIRole: Codable {
    let id: String
    let title: String
    let description: String
    let industryId: String
    let industryName: String?
    let hierarchyLevel: String
    let searchKeywords: [String]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case industryId = "industry_id"
        case industryName = "industry_name"
        case hierarchyLevel = "hierarchy_level"
        case searchKeywords = "search_keywords"
        case isActive = "is_active"
    }
}

struct RoleMatch: Codable {
    let id: String
    let title: String
    let description: String
    let industryName: String
    let hierarchyLevel: String
    let searchKeywords: [String]
    let relevanceScore: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case industryName = "industry_name"
        case hierarchyLevel = "hierarchy_level"
        case searchKeywords = "search_keywords"
        case relevanceScore = "relevance_score"
    }
}

struct UserJobInput: Codable {
    let jobTitle: String
    let jobDescription: String
    let userIndustry: String
    
    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case jobDescription = "job_description"
        case userIndustry = "user_industry"
    }
}

struct RoleMatchResponse: Codable {
    let success: Bool
    let userJobInput: UserJobInput
    let matchedRoles: [RoleMatch]
    let totalMatches: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case userJobInput = "user_job_input"
        case matchedRoles = "matched_roles"
        case totalMatches = "total_matches"
    }
}

struct RoleSelectionRequest: Codable {
    let roleId: String
    
    enum CodingKeys: String, CodingKey {
        case roleId = "role_id"
    }
}

struct CreateCustomRoleRequest: Codable {
    let jobTitle: String
    let jobDescription: String
    let hierarchyLevel: String
    
    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case jobDescription = "job_description"
        case hierarchyLevel = "hierarchy_level"
    }
}

// MARK: - Phase 2: Communication Partners & Units

struct CommunicationPartner: Codable {
    let id: String
    let name: String
    let description: String
    let partnerType: String
    let isActive: Bool
    let sortOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case partnerType = "partner_type"
        case isActive = "is_active"
        case sortOrder = "sort_order"
    }
}

struct CommunicationPartnersResponse: Codable {
    let partners: [CommunicationPartner]
}

struct PartnerSelection: Codable {
    let communicationPartnerId: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case communicationPartnerId = "communication_partner_id"
        case priority
    }
}

struct SelectPartnersRequest: Codable {
    let partnerSelections: [PartnerSelection]
    
    enum CodingKeys: String, CodingKey {
        case partnerSelections = "partner_selections"
    }
}

struct UserPartner: Codable {
    let id: String
    let communicationPartner: CommunicationPartner
    let priority: Int
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case communicationPartner = "communication_partner"
        case priority
        case isActive = "is_active"
    }
}

struct UserPartnersResponse: Codable {
    let partners: [UserPartner]
}

// Communication Units (Situations)
struct CommunicationUnit: Codable {
    let id: String
    let name: String
    let description: String
    let unitType: String
    let skillsFocus: [String]
    let difficultyLevel: Int
    let isBeginnerFriendly: Bool
    let isAdvanced: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case unitType = "unit_type"
        case skillsFocus = "skills_focus"
        case difficultyLevel = "difficulty_level"
        case isBeginnerFriendly = "is_beginner_friendly"
        case isAdvanced = "is_advanced"
    }
}

struct PartnerUnitsResponse: Codable {
    let units: [CommunicationUnit]
}

struct UnitSelection: Codable {
    let unitId: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case unitId = "unit_id"
        case priority
    }
}

struct SelectUnitsRequest: Codable {
    let unitSelections: [UnitSelection]
    
    enum CodingKeys: String, CodingKey {
        case unitSelections = "unit_selections"
    }
}

struct UserUnit: Codable {
    let id: String
    let communicationUnit: CommunicationUnit
    let priority: Int
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case communicationUnit = "communication_unit"
        case priority
        case isActive = "is_active"
    }
}

struct UserUnitsResponse: Codable {
    let units: [UserUnit]
}

// MARK: - Onboarding Summary

struct OnboardingSummary: Codable {
    let user: User
    let onboardingStatus: String
    let currentPhase: String
    let progress: Int
    let completedSteps: [String]
    let nextStep: String?
    
    // Phase 1 Data
    let selectedLanguage: String?
    let selectedIndustry: APIIndustry?
    let selectedRole: APIRole?
    
    // Phase 2 Data
    let selectedPartners: [UserPartner]
    let partnerUnitSelections: [String: [UserUnit]] // partner_id -> units
    
    enum CodingKeys: String, CodingKey {
        case user
        case onboardingStatus = "onboarding_status"
        case currentPhase = "current_phase"
        case progress
        case completedSteps = "completed_steps"
        case nextStep = "next_step"
        case selectedLanguage = "selected_language"
        case selectedIndustry = "selected_industry"
        case selectedRole = "selected_role"
        case selectedPartners = "selected_partners"
        case partnerUnitSelections = "partner_unit_selections"
    }
}

// MARK: - Standard API Response Wrappers

struct OnboardingAPIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

// Empty response for endpoints that don't return data
struct EmptyOnboardingResponse: Codable {}