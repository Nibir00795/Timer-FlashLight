//
//  AppTheme.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

/// Design system for Timer FlashLight app
/// Contains colors, typography, spacing, and other design tokens
struct AppTheme {
    // MARK: - Colors
    
    struct Colors {
        // Background colors
        static let background = Color(hex: "222222")
        static let cardBackground = Color(hex: "444444")
        
        // Accent/Success
        static let success = Color(hex: "44D62C")
        
        // Border
        static let border = Color(hex: "666666")
        
        // Bottom sheet
        static let sheetGrabber = Color(hex: "9E9E9E")       // Light grey drag handle
        static let sliderTrackInactive = Color(hex: "555555") // Dark grey slider track
        static let bottomSheetBackground = Color(hex: "606060") // Bottom sheet main background
        static let controlAreaBackground = Color(hex: "444444") // Brightness bar, timer, home icon area
        
        // Text colors
        static let textPrimary = Color(hex: "FFFFFF")      // White
        static let textSecondary = Color(hex: "000000")    // Black
        static let textTertiary = Color(hex: "CCCCCC")     // Light gray
        static let textLight = Color(hex: "E6E6E6")        // Very light gray
        static let textMuted = Color(hex: "BABABA")        // Medium gray
        static let textDark = Color(hex: "232122")         // Dark gray
        static let textSuccess = Color(hex: "44D62C")      // Green (same as success)
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Font families
        static let sairaFontName = "Saira"
        static let soraFontName = "Sora"
        
        // Saira font styles (Variable font - weight is handled by the font itself)
        static func saira(size: CGFloat, weight: Font.Weight = .regular, lineHeight: CGFloat? = nil) -> Font {
            // Variable fonts handle weight internally
            return .custom(sairaFontName, size: size)
        }
        
        // Sora font styles (Variable font - weight is handled by the font itself)
        static func sora(size: CGFloat, weight: Font.Weight = .regular, lineHeight: CGFloat? = nil) -> Font {
            // Variable fonts handle weight internally
            return .custom(soraFontName, size: size)
        }
        
        // Predefined text styles (based on design specs)
        
        // Headline - Saira 16px, 700, line-height 28px
        static let headline = saira(size: 16, weight: .bold)
        
        // Body - Saira 16px, 400, line-height 20px
        static let body = saira(size: 16, weight: .regular)
        
        // Body Light - Saira 16px, 300, line-height 20px
        static let bodyLight = saira(size: 16, weight: .light)
        
        // Body Bold - Saira 16px, 700
        static let bodyBold = saira(size: 16, weight: .bold)
        
        // Title - Saira 20px, 400
        static let title = saira(size: 20, weight: .regular)
        
        // Title Success - Saira 20px, 400, color #44D62C
        static let titleSuccess = saira(size: 20, weight: .regular)
        
        // Caption - Saira 13px, 500, line-height 20px
        static let caption = saira(size: 13, weight: .medium)
        
        // Body Sora - Sora 16px, 400, line-height 20px
        static let bodySora = sora(size: 16, weight: .regular)
        
        // Body Sora Light - Sora 16px, 400, color #CCC
        static let bodySoraLight = sora(size: 16, weight: .regular)
        
        // Body Sora Very Light - Sora 16px, 400, color #E6E6E6
        static let bodySoraVeryLight = sora(size: 16, weight: .regular)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 64
        static let xxxl: CGFloat = 72
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let small: CGFloat = 9
        static let medium: CGFloat = 20
        static let large: CGFloat = 30
        static let extraLarge: CGFloat = 100
    }
    
    // MARK: - Borders
    
    struct Border {
        static let width: CGFloat = 1
        static let color = Colors.border
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex string (e.g., "FF0000" or "#FF0000" or "FFFF0000" for ARGB)
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
}
