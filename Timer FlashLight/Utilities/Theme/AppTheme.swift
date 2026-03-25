//
//  AppTheme.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit

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
        
        /// Scale factor for point sizes on iPad (1.25); 1.0 on phone.
        static var contentScale: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 1.25 : 1.0 }
        /// Use for explicit font sizes so they scale on iPad (e.g. .font(.custom(..., size: Typography.scaledSize(24)))).
        static func scaledSize(_ size: CGFloat) -> CGFloat { size * contentScale }
        
        // Saira font styles (size is scaled on iPad)
        static func saira(size: CGFloat, weight: Font.Weight = .regular, lineHeight: CGFloat? = nil) -> Font {
            return .custom(sairaFontName, size: size * contentScale)
        }
        
        // Sora font styles (size is scaled on iPad)
        static func sora(size: CGFloat, weight: Font.Weight = .regular, lineHeight: CGFloat? = nil) -> Font {
            return .custom(soraFontName, size: size * contentScale)
        }
        
        // Predefined text styles (base sizes; saira/sora already apply contentScale)
        static var headline: Font { saira(size: 16, weight: .bold) }
        static var body: Font { saira(size: 16, weight: .regular) }
        static var bodyLight: Font { saira(size: 16, weight: .light) }
        static var bodyBold: Font { saira(size: 16, weight: .bold) }
        static var title: Font { saira(size: 20, weight: .regular) }
        static var titleSuccess: Font { saira(size: 20, weight: .regular) }
        static var caption: Font { saira(size: 13, weight: .medium) }
        static var bodySora: Font { sora(size: 16, weight: .regular) }
        static var bodySoraLight: Font { sora(size: 16, weight: .regular) }
        static var bodySoraVeryLight: Font { sora(size: 16, weight: .regular) }
    }
    
    // MARK: - Spacing (scaled on iPad)
    
    struct Spacing {
        private static var scale: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 1.25 : 1.0 }
        static var xs: CGFloat { 8 * scale }
        static var sm: CGFloat { 12 * scale }
        static var md: CGFloat { 16 * scale }
        static var lg: CGFloat { 24 * scale }
        static var xl: CGFloat { 32 * scale }
        static var xxl: CGFloat { 64 * scale }
        static var xxxl: CGFloat { 72 * scale }
    }
    
    // MARK: - Corner Radius (scaled on iPad)
    
    struct CornerRadius {
        private static var scale: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 1.25 : 1.0 }
        static var small: CGFloat { 9 * scale }
        static var medium: CGFloat { 20 * scale }
        static var large: CGFloat { 30 * scale }
        static var extraLarge: CGFloat { 100 * scale }
    }
    
    // MARK: - Borders
    
    struct Border {
        private static var scale: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 1.25 : 1.0 }
        static var width: CGFloat { 1 * scale }
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
