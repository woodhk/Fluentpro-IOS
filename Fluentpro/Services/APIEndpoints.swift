//
//  APIEndpoints.swift
//  Fluentpro
//
//  Created on 30/05/2025.
//

import Foundation

enum APIEndpoints {
    // MARK: - Base Configuration
    private static let baseURL = "https://api.fluentpro.com" // Replace with your actual base URL
    private static let apiVersion = "v1"
    
    // MARK: - Authentication Endpoints
    case login
    case signup
    case refreshToken
    case logout
    case auth0Callback
    
    // MARK: - User Endpoints
    case userProfile
    case updateProfile
    
    // MARK: - Other Endpoints (add as needed)
    case lessons
    case lessonDetail(id: String)
    case progress
    
    // MARK: - URL Building
    var path: String {
        switch self {
        // Authentication
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/signup"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .auth0Callback:
            return "/auth/auth0/callback"
            
        // User
        case .userProfile:
            return "/user/profile"
        case .updateProfile:
            return "/user/profile/update"
            
        // Other endpoints
        case .lessons:
            return "/lessons"
        case .lessonDetail(let id):
            return "/lessons/\(id)"
        case .progress:
            return "/user/progress"
        }
    }
    
    var url: URL? {
        let urlString = "\(APIEndpoints.baseURL)/\(APIEndpoints.apiVersion)\(path)"
        return URL(string: urlString)
    }
    
    // MARK: - HTTP Methods
    var httpMethod: String {
        switch self {
        case .login, .signup, .refreshToken, .logout, .auth0Callback:
            return "POST"
        case .userProfile, .lessons, .lessonDetail, .progress:
            return "GET"
        case .updateProfile:
            return "PUT"
        }
    }
    
    // MARK: - Headers
    var headers: [String: String] {
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Add additional headers based on endpoint if needed
        switch self {
        case .refreshToken, .logout, .userProfile, .updateProfile, .lessons, .lessonDetail, .progress:
            // These endpoints require authentication
            // Token will be added by NetworkService
            break
        default:
            break
        }
        
        return headers
    }
    
    // MARK: - Configuration Methods
    static func configure(baseURL: String) {
        // This would need to be stored in a more permanent way
        // For now, you can update the baseURL constant above
    }
    
    static func getFullURL(for endpoint: APIEndpoints) -> URL? {
        return endpoint.url
    }
}