import Foundation
import UIKit

// MARK: - Validators
struct Validators {
    
    // MARK: - Email Validation
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation
    struct PasswordValidation {
        let isValid: Bool
        let errors: [String]
    }
    
    static func validatePassword(_ password: String, 
                               minLength: Int = 8,
                               requireUppercase: Bool = true,
                               requireLowercase: Bool = true,
                               requireNumber: Bool = true,
                               requireSpecialCharacter: Bool = true) -> PasswordValidation {
        var errors: [String] = []
        
        // Check minimum length
        if password.count < minLength {
            errors.append("Password must be at least \(minLength) characters long")
        }
        
        // Check for uppercase letter
        if requireUppercase && !password.contains(where: { $0.isUppercase }) {
            errors.append("Password must contain at least one uppercase letter")
        }
        
        // Check for lowercase letter
        if requireLowercase && !password.contains(where: { $0.isLowercase }) {
            errors.append("Password must contain at least one lowercase letter")
        }
        
        // Check for number
        if requireNumber && !password.contains(where: { $0.isNumber }) {
            errors.append("Password must contain at least one number")
        }
        
        // Check for special character
        if requireSpecialCharacter {
            let specialCharacterRegex = ".*[!@#$%^&*(),.?\":{}|<>].*"
            let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex)
            if !specialCharacterPredicate.evaluate(with: password) {
                errors.append("Password must contain at least one special character")
            }
        }
        
        return PasswordValidation(isValid: errors.isEmpty, errors: errors)
    }
    
    // MARK: - Date Validation
    static func isValidDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.date(from: dateString) != nil
    }
    
    static func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
    
    static func isDateInPast(_ date: Date) -> Bool {
        return date < Date()
    }
    
    static func isDateWithinRange(_ date: Date, from startDate: Date, to endDate: Date) -> Bool {
        return date >= startDate && date <= endDate
    }
    
    // MARK: - Phone Number Validation
    static func isValidPhoneNumber(_ phoneNumber: String, countryCode: String = "US") -> Bool {
        let phoneNumberKit = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        switch countryCode {
        case "US":
            // US phone numbers should be 10 digits (excluding country code)
            return phoneNumberKit.count == 10 || (phoneNumberKit.count == 11 && phoneNumberKit.hasPrefix("1"))
        default:
            // Basic validation for other countries (between 7 and 15 digits)
            return phoneNumberKit.count >= 7 && phoneNumberKit.count <= 15
        }
    }
    
    // MARK: - Name Validation
    static func isValidName(_ name: String, minLength: Int = 2, maxLength: Int = 50) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check length
        if trimmedName.count < minLength || trimmedName.count > maxLength {
            return false
        }
        
        // Check for valid characters (letters, spaces, hyphens, apostrophes)
        let nameRegex = "^[a-zA-Z\\s'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        
        return namePredicate.evaluate(with: trimmedName)
    }
    
    // MARK: - URL Validation
    static func isValidURL(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    // MARK: - Credit Card Validation (Basic Luhn Algorithm)
    static func isValidCreditCard(_ cardNumber: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        guard cleanedCardNumber.count >= 13 && cleanedCardNumber.count <= 19 else {
            return false
        }
        
        var sum = 0
        let reversedCharacters = cleanedCardNumber.reversed().map { String($0) }
        
        for (index, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            
            switch index % 2 {
            case 1:
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
}