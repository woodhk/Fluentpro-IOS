//
//  OnboardingModels.swift
//  Fluentpro
//
//  Created on 31/05/2025.
//

import Foundation

// MARK: - Language
enum Language: String, CaseIterable, Identifiable, Codable {
    case english = "English"
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    case italian = "Italian"
    case portuguese = "Portuguese"
    case russian = "Russian"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case korean = "Korean"
    case arabic = "Arabic"
    case hindi = "Hindi"
    
    var id: String { rawValue }
}

// MARK: - Industry
enum Industry: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case finance = "Finance"
    case healthcare = "Healthcare"
    case retail = "Retail"
    case manufacturing = "Manufacturing"
    case education = "Education"
    case hospitality = "Hospitality"
    case consulting = "Consulting"
    case realEstate = "Real Estate"
    case marketing = "Marketing & Advertising"
    case legal = "Legal"
    case logistics = "Logistics & Supply Chain"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .technology: return "laptopcomputer"
        case .finance: return "chart.line.uptrend.xyaxis"
        case .healthcare: return "heart.text.square"
        case .retail: return "cart"
        case .manufacturing: return "gearshape.2"
        case .education: return "graduationcap"
        case .hospitality: return "bed.double"
        case .consulting: return "person.3"
        case .realEstate: return "house"
        case .marketing: return "megaphone"
        case .legal: return "scale.3d"
        case .logistics: return "shippingbox"
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
    
    init(id: String = UUID().uuidString, title: String, description: String, industry: String, commonTasks: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.industry = industry
        self.commonTasks = commonTasks
    }
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
    var matchedRole: Role?
    var conversationMessages: [AIConversationMessage] = []
    var identifiedNeeds: [String] = []
    var selectedCourse: Course?
    var availableCourses: [Course] = []
    
    var isPhase1Complete: Bool {
        nativeLanguage != nil && industry != nil && !roleTitle.isEmpty && !roleDescription.isEmpty
    }
    
    var isPhase2Complete: Bool {
        conversationMessages.count >= 6 && !identifiedNeeds.isEmpty
    }
}

// MARK: - API Models (for future backend integration)
struct RoleMatchRequest: Codable {
    let title: String
    let description: String
    let industry: String
}

struct RoleMatchResponse: Codable {
    let matched: Bool
    let role: Role?
    let confidence: Double?
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