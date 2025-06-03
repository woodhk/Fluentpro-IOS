//
//  OnboardingModels.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import Foundation

// MARK: - Language
enum Language: String, CaseIterable, Identifiable, Codable {
    case english = "english"
    case spanish = "spanish"
    case french = "french"
    case german = "german"
    case italian = "italian"
    case portuguese = "portuguese"
    case russian = "russian"
    case chinese = "chinese"
    case japanese = "japanese"
    case korean = "korean"
    case arabic = "arabic"
    case hindi = "hindi"
    
    var id: String { rawValue }
    
    // Display name for UI
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        }
    }
}

// MARK: - Industry
enum Industry: String, CaseIterable, Identifiable {
    case bankingFinance = "Banking & Finance"
    case shippingLogistics = "Shipping & Logistics"
    case realEstate = "Real Estate"
    case hotelsHospitality = "Hotels & Hospitality"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bankingFinance: return "chart.line.uptrend.xyaxis"
        case .shippingLogistics: return "shippingbox"
        case .realEstate: return "house"
        case .hotelsHospitality: return "bed.double"
        }
    }
}

// MARK: - Role
struct Role: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let industry: String
    let commonTasks: [String]
    let confidence: Double? // For AI matching confidence
    
    init(id: String = UUID().uuidString, title: String, description: String, industry: String, commonTasks: [String] = [], confidence: Double? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.industry = industry
        self.commonTasks = commonTasks
        self.confidence = confidence
    }
}

// MARK: - Conversation Partners
enum ConversationPartner: String, CaseIterable, Identifiable {
    case clients = "Clients"
    case customers = "Customers"
    case colleagues = "Colleagues"
    case suppliers = "Suppliers"
    case partners = "Partners"
    case seniorManagement = "Senior Management"
    case stakeholders = "Stakeholders"
    case other = "Other"
    
    var id: String { rawValue }
}

// MARK: - Conversation Situations
enum ConversationSituation: String, CaseIterable, Identifiable {
    case interviews = "Interviews"
    case conflictResolution = "Conflict Resolution"
    case phoneCalls = "Phone Calls"
    case oneOnOnes = "One-on-Ones"
    case feedbackSessions = "Feedback Sessions"
    case teamDiscussions = "Team Discussions"
    case negotiations = "Negotiations"
    case statusUpdates = "Status Updates"
    case informalChats = "Informal Chats"
    case briefings = "Briefings"
    case meetings = "Meetings"
    case presentations = "Presentations"
    case trainingSessions = "Training Sessions"
    case clientConversations = "Client Conversations"
    case videoConferences = "Video Conferences"
    
    var id: String { rawValue }
}

// MARK: - Partner Situations Mapping
struct PartnerSituations: Identifiable {
    let id = UUID()
    let partner: ConversationPartner
    var situations: Set<ConversationSituation> = []
}

// MARK: - Course Models
struct Course: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let effectiveness: CourseEffectiveness
    let functionalLanguage: [String]
    let lessons: [Lesson]
    let estimatedDuration: String // e.g., "4 weeks"
    let level: String // e.g., "Intermediate"
    
    struct CourseEffectiveness: Codable {
        let rating: Double // 0-5
        let improvementAreas: [String]
        let targetSkills: [String]
    }
}

struct Lesson: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let keyLanguage: [String]
    let summary: String
    let scenarios: [Scenario]
    let orderIndex: Int
}

struct Scenario: Identifiable, Codable {
    let id: String
    let title: String
    let context: String
    let objective: String
    let dialogueExample: String
    let keyPhrases: [String]
}

// MARK: - AI Conversation
struct AIConversationMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

// MARK: - Onboarding Data Container
struct OnboardingData {
    var nativeLanguage: Language?
    var industry: Industry?
    var roleTitle: String = ""
    var roleDescription: String = ""
    var matchedRoles: [Role] = [] // Now stores multiple roles with confidence scores
    var selectedRole: Role? // The role user selected
    var didSelectNoMatch: Bool = false // If user selected "none of these are my role"
    
    // Phase 2 data
    var selectedConversationPartners: Set<ConversationPartner> = []
    var partnerSituations: [PartnerSituations] = []
    var currentPartnerIndex: Int = 0
    
    var isPhase1Complete: Bool {
        nativeLanguage != nil && 
        industry != nil && 
        !roleTitle.isEmpty && 
        !roleDescription.isEmpty &&
        (selectedRole != nil || didSelectNoMatch)
    }
    
    var isPhase2Complete: Bool {
        !selectedConversationPartners.isEmpty &&
        partnerSituations.count == selectedConversationPartners.count &&
        partnerSituations.allSatisfy { !$0.situations.isEmpty }
    }
    
    var currentPartnerForSituations: ConversationPartner? {
        guard currentPartnerIndex < Array(selectedConversationPartners).count else { return nil }
        return Array(selectedConversationPartners).sorted(by: { $0.rawValue < $1.rawValue })[currentPartnerIndex]
    }
}

// MARK: - API Models (for future backend integration)
struct RoleMatchRequest: Codable {
    let title: String
    let description: String
    let industry: String
}


struct CourseRecommendationRequest: Codable {
    let roleId: String?
    let industry: String
    let identifiedNeeds: [String]
    let nativeLanguage: String
}

struct CourseRecommendationResponse: Codable {
    let courses: [Course]
    let customCoursesBeingCreated: Bool
    let estimatedCreationTime: String?
}

// MARK: - Language Extension
extension Language {
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .russian: return "🇷🇺"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        }
    }
}