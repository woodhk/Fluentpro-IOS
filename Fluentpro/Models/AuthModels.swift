import Foundation

// MARK: - Login Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let token: AuthToken?
    let user: Fluentpro.User?
}

// MARK: - Sign Up Models
struct SignUpRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let dateOfBirth: String
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email
        case password
        case dateOfBirth = "date_of_birth"
    }
}

struct SignUpResponse: Codable {
    let success: Bool
    let message: String?
    let token: AuthToken?
    let user: Fluentpro.User?
}

// MARK: - Auth Token
struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresAt
        case tokenType
    }
}