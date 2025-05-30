import SwiftUI

struct Theme {
    // MARK: - Colors
    static let primaryColor = Color(hex: "#234BFF")
    
    // MARK: - Spacing
    static let spacing = Spacing()
    
    // MARK: - Typography
    static let typography = Typography()
    
    // MARK: - Corner Radius
    static let cornerRadius = CornerRadius()
}

// MARK: - Spacing
extension Theme {
    struct Spacing {
        let xxxSmall: CGFloat = 2
        let xxSmall: CGFloat = 4
        let xSmall: CGFloat = 8
        let small: CGFloat = 12
        let medium: CGFloat = 16
        let large: CGFloat = 24
        let xLarge: CGFloat = 32
        let xxLarge: CGFloat = 48
        let xxxLarge: CGFloat = 64
    }
}

// MARK: - Typography
extension Theme {
    struct Typography {
        let largeTitle = Font.largeTitle
        let title = Font.title
        let title2 = Font.title2
        let title3 = Font.title3
        let headline = Font.headline
        let body = Font.body
        let callout = Font.callout
        let subheadline = Font.subheadline
        let footnote = Font.footnote
        let caption = Font.caption
        let caption2 = Font.caption2
    }
}

// MARK: - Corner Radius
extension Theme {
    struct CornerRadius {
        let small: CGFloat = 4
        let medium: CGFloat = 8
        let large: CGFloat = 12
        let xLarge: CGFloat = 16
        let xxLarge: CGFloat = 24
    }
}