import Foundation

// MARK: - Standard API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
    let details: [String: Any]?
    let errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
        case error
        case details
        case errorCode = "error_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
        
        // Handle details as generic dictionary
        if let detailsData = try? container.decodeIfPresent(Data.self, forKey: .details),
           let detailsDict = try? JSONSerialization.jsonObject(with: detailsData) as? [String: Any] {
            details = detailsDict
        } else {
            details = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(errorCode, forKey: .errorCode)
        
        if let details = details,
           let detailsData = try? JSONSerialization.data(withJSONObject: details) {
            try container.encode(detailsData, forKey: .details)
        }
    }
}

// MARK: - Empty Response
struct EmptyData: Codable {}