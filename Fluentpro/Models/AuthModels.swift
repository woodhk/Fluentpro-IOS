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
    let dateOfBirth: Date
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case email
        case password
        case dateOfBirth
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