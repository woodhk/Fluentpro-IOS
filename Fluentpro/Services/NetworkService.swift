//
//  NetworkService.swift
//  Fluentpro
//
//  Created on 30/05/2025.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case networkError(Error)
    case unauthorized
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access. Please login again."
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Token storage (consider using Keychain for production)
    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        // Note: Using manual CodingKeys for field mapping instead of automatic conversion
        
        self.encoder = JSONEncoder()
        // Note: Using manual CodingKeys for field mapping instead of automatic conversion
    }
    
    // MARK: - Token Management
    func setAuthToken(_ token: String?) {
        authToken = token
    }
    
    func getAuthToken() -> String? {
        return authToken
    }
    
    func clearAuthToken() {
        authToken = nil
    }
    
    // MARK: - Generic Request Method
    private func request<T: Decodable>(
        endpoint: APIEndpoints,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        
        // Set headers
        var headers = endpoint.headers
        
        // Only add auth token for endpoints that require authentication
        let requiresAuth: Bool
        switch endpoint {
        case .login, .signup, .auth0Callback:
            requiresAuth = false
        default:
            requiresAuth = true
        }
        
        if requiresAuth, let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        // Debug: Print request details
        print("🚀 Making request to: \(request.url?.absoluteString ?? "unknown")")
        print("📋 Method: \(request.httpMethod ?? "unknown")")
        print("📋 Headers:")
        for (key, value) in headers {
            print("   \(key): \(value)")
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📋 Request body: \(bodyString)")
        }
        
        // Set body
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(NSError(domain: "Invalid response", code: -1))
            }
            
            // Debug: Always log the status code and response for debugging
            print("🌐 HTTP \(httpResponse.statusCode) - \(request.url?.absoluteString ?? "unknown URL")")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response: \(responseString)")
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                break
            case 401:
                throw NetworkError.unauthorized
            case 403:
                // Handle forbidden errors specifically
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    let message = errorResponse.message ?? errorResponse.error ?? errorResponse.detail ?? "Access forbidden"
                    throw NetworkError.serverError(message: "Forbidden: \(message)")
                }
                // Debug: Print raw 403 response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 403 Forbidden response:")
                    print(responseString)
                }
                throw NetworkError.serverError(message: "Access forbidden")
            case 400...499:
                // Try to decode error message from server
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    let message = errorResponse.message ?? errorResponse.error ?? errorResponse.detail ?? "Request failed"
                    throw NetworkError.serverError(message: message)
                }
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            case 500...599:
                throw NetworkError.serverError(message: "Internal server error")
            default:
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            // Decode response
            do {
                let decodedResponse = try decoder.decode(responseType, from: data)
                return decodedResponse
            } catch {
                // Debug: Print response for 4xx/5xx errors
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 Failed to decode response. Raw response:")
                    print(responseString)
                }
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Public Methods
    
    // GET request
    func get<T: Decodable>(
        endpoint: APIEndpoints,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            responseType: responseType
        )
    }
    
    // POST request with Encodable body
    func post<T: Decodable, B: Encodable>(
        endpoint: APIEndpoints,
        body: B,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try encoder.encode(body)
        return try await request(
            endpoint: endpoint,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // POST request without body
    func post<T: Decodable>(
        endpoint: APIEndpoints,
        responseType: T.Type
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            responseType: responseType
        )
    }
    
    // PUT request
    func put<T: Decodable, B: Encodable>(
        endpoint: APIEndpoints,
        body: B,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try encoder.encode(body)
        return try await request(
            endpoint: endpoint,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // DELETE request
    func delete(endpoint: APIEndpoints) async throws {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Set headers
        var headers = endpoint.headers
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError(NSError(domain: "Invalid response", code: -1))
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: nil)
        }
    }
    
    // MARK: - Response Models
    struct ErrorResponse: Decodable {
        let message: String?
        let code: String?
        let error: String?
        let detail: String?
    }
}

struct EmptyResponse: Decodable {}