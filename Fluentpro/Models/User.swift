import Foundation

struct User: Codable {
    let id: String
    let fullName: String
    let email: String
    let dateOfBirth: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case dateOfBirth = "date_of_birth"
    }
    
    // Computed property to get Date from string
    var dateOfBirthAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateOfBirth)
    }
}