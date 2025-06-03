import Foundation

struct User: Codable {
    let id: String
    let fullName: String
    let email: String
    let dateOfBirth: String
    let auth0Id: String?
    let isActive: Bool?
    let nativeLanguage: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case dateOfBirth = "date_of_birth"
        case auth0Id = "auth0_id"
        case isActive = "is_active"
        case nativeLanguage = "native_language"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Computed property to get Date from string
    var dateOfBirthAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateOfBirth)
    }
}

// MARK: - User Profile Industry Object
struct UserProfileIndustry: Codable {
    let id: String
    let name: String?
}

// MARK: - User Profile Role Object  
struct UserProfileRole: Codable {
    let id: String
    let title: String?
    let description: String?
}

// MARK: - User Profile (Extended model with onboarding data)
struct UserProfile: Codable {
    let success: Bool?
    let id: String
    let fullName: String
    let email: String
    let dateOfBirth: String
    let nativeLanguage: String?
    let industry: UserProfileIndustry?
    let role: UserProfileRole?
    let onboardingStatus: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case id
        case fullName = "full_name"
        case email
        case dateOfBirth = "date_of_birth"
        case nativeLanguage = "native_language"
        case industry
        case role
        case onboardingStatus = "onboarding_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Computed property to get User object
    var user: User {
        return User(
            id: id,
            fullName: fullName,
            email: email,
            dateOfBirth: dateOfBirth,
            auth0Id: nil,
            isActive: true,
            nativeLanguage: nativeLanguage,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Onboarding Status
enum OnboardingStatus: String, Codable {
    case pending = "pending"
    case welcome = "welcome"
    case basicInfo = "basic_info"
    case personalisation = "personalisation"
    case courseAssignment = "course_assignment"
    case completed = "completed"
}