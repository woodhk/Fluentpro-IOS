import SwiftUI

extension Color {
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - App Colors
    static var primary: Color {
        Theme.primaryColor
    }
    
    // MARK: - Semantic Colors
    static var background: Color {
        Color(UIColor.systemBackground)
    }
    
    static var secondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var tertiaryBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
    
    static var groupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
    
    static var secondaryGroupedBackground: Color {
        Color(UIColor.secondarySystemGroupedBackground)
    }
    
    static var label: Color {
        Color(UIColor.label)
    }
    
    static var secondaryLabel: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var tertiaryLabel: Color {
        Color(UIColor.tertiaryLabel)
    }
    
    static var separator: Color {
        Color(UIColor.separator)
    }
    
    static var opaqueSeparator: Color {
        Color(UIColor.opaqueSeparator)
    }
}

// MARK: - Theme Colors
extension Color {
    static let theme = ColorTheme()
    
    struct ColorTheme {
        let primary = Color(hex: "#234BFF")
        let background = Color(UIColor.systemBackground)
        let secondaryBackground = Color(UIColor.secondarySystemBackground)
        let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        let primaryText = Color(UIColor.label)
        let secondaryText = Color(UIColor.secondaryLabel)
        let tertiaryText = Color(UIColor.tertiaryLabel)
        let border = Color(UIColor.separator)
        let error = Color(UIColor.systemRed)
        let success = Color(UIColor.systemGreen)
        let warning = Color(UIColor.systemOrange)
    }
}