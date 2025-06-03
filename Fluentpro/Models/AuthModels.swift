import Foundation

// MARK: - Login Models
struct LoginRequest: Codable {
    let email: String
    let password: String
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

// MARK: - Auth Response (used for both login and signup)
struct AuthResponse: Codable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: Fluentpro.User
    
    enum CodingKeys: String, CodingKey {
        case success
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}

// MARK: - Refresh Token
struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - Auth0 Callback
struct Auth0CallbackRequest: Codable {
    let code: String
    let state: String?
}

// MARK: - API Error Response
struct APIErrorResponse: Codable {
    let success: Bool
    let error: String?
    let details: String?
    let errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case error
        case details
        case errorCode = "error_code"
    }
}