//
//  APIEndpoints.swift
//  Fluentpro
//
//  Created on 30/05/2025.
//

import Foundation

enum APIEndpoints {
    // MARK: - Base Configuration
    private static let baseURL = "https://fluentpro-backend.onrender.com" // Replace with your actual base URL
    private static let apiVersion = "api/v1"
    
    // MARK: - Authentication Endpoints
    case login
    case signup

    case refreshToken
    case logout
    case auth0Callback
    
    // MARK: - User Endpoints
    case userProfile
    case updateProfile
    
    // MARK: - Role Management Endpoints
    case jobInput
    case roleSelection(roleId: String)
    case createCustomRole
    
    // MARK: - Onboarding Endpoints
    // Phase 1
    case setLanguage
    case getLanguages
    case setIndustry
    case getIndustries
    
    // Phase 2
    case getCommunicationPartners
    case selectCommunicationPartners
    case getUserPartners
    case getPartnerUnits(partnerId: String)
    case selectPartnerUnits(partnerId: String)
    case getUserPartnerUnits(partnerId: String)
    
    // Summary
    case getOnboardingSummary
    
    // MARK: - Other Endpoints (add as needed)
    case lessons
    case lessonDetail(id: String)
    case progress
    
    // MARK: - URL Building
    var path: String {
        switch self {
        // Authentication
        case .login:
            return "/auth/login/"
        case .signup:
            return "/auth/signup/"
        case .refreshToken:
            return "/auth/refresh/"
        case .logout:
            return "/auth/logout/"
        case .auth0Callback:
            return "/auth/callback/"
            
        // User
        case .userProfile:
            return "/user/profile/"
        case .updateProfile:
            return "/user/profile/"
            
        // Role Management
        case .jobInput:
            return "/roles/job-input/"
        case .roleSelection(let roleId):
            return "/roles/role-selection/"
        case .createCustomRole:
            return "/roles/new-role/"
            
        // Onboarding - Phase 1
        case .setLanguage:
            return "/onboarding/set-language/"
        case .getLanguages:
            return "/onboarding/languages/"
        case .setIndustry:
            return "/onboarding/set-industry/"
        case .getIndustries:
            return "/onboarding/industries/"
            
        // Onboarding - Phase 2
        case .getCommunicationPartners:
            return "/onboarding/communication-partners/"
        case .selectCommunicationPartners:
            return "/onboarding/select-partners/"
        case .getUserPartners:
            return "/onboarding/user-partners/"
        case .getPartnerUnits(let partnerId):
            return "/onboarding/partner/\(partnerId)/units/"
        case .selectPartnerUnits(let partnerId):
            return "/onboarding/partner/\(partnerId)/select-units/"
        case .getUserPartnerUnits(let partnerId):
            return "/onboarding/partner/\(partnerId)/user-units/"
            
        // Onboarding - Summary
        case .getOnboardingSummary:
            return "/onboarding/summary/"
            
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
            return "PATCH"
            
        // Role Management
        case .jobInput, .roleSelection, .createCustomRole:
            return "POST"
            
        // Onboarding
        case .setLanguage, .setIndustry, .selectCommunicationPartners, .selectPartnerUnits:
            return "POST"
        case .getLanguages, .getIndustries, .getCommunicationPartners, .getUserPartners,
             .getPartnerUnits, .getUserPartnerUnits, .getOnboardingSummary:
            return "GET"
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
        case .refreshToken, .logout, .userProfile, .updateProfile, .lessons, .lessonDetail, .progress,
             .jobInput, .roleSelection, .createCustomRole,
             .setLanguage, .setIndustry, .getLanguages, .getIndustries,
             .getCommunicationPartners, .selectCommunicationPartners, .getUserPartners,
             .getPartnerUnits, .selectPartnerUnits, .getUserPartnerUnits,
             .getOnboardingSummary:
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
