import Foundation

struct User: Codable {
    let id: String
    let fullName: String
    let email: String
    let dateOfBirth: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case dateOfBirth
    }
}