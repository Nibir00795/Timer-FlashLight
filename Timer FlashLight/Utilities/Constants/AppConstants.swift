//
//  AppConstants.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation

struct AppConstants {
    // MARK: - Timer Constants
    struct Timer {
        static let defaultDuration: TimeInterval = 60.0
        static let minDuration: TimeInterval = 1.0
        static let maxDuration: TimeInterval = 3600.0
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12.0
        static let padding: CGFloat = 16.0
    }
    
    // MARK: - Layout Constants (Device-Specific Spacing)
    struct Layout {
        // Top section
        static let upgradeButtonTopSpacing: CGFloat = 18.0 // Upgrade btn to safe area top
        static let batteryLeftSpacing: CGFloat = 40.0 // Battery to left edge
        static let menuRightSpacing: CGFloat = 40.0 // Menu btn to right edge
        
        // SOS button
        static let sosButtonTopSpacing: CGFloat = 46.0 // SOS btn top to upgrade btn bottom
        static let sosButtonSpacing: CGFloat = 40.0 // Spacing between SOS and control buttons
        
        // Bottom section (one content area = same visible left/right edges for brightness + timer row)
        static let bottomNavTopSpacing: CGFloat = 80.0 // Bottom nav to bottom safe area
        static let bottomNavHorizontalSpacing: CGFloat = 40.0 // From screen edge to content
        static let bottomNavContentInset: CGFloat = 16.0 // Extra inner inset
        /// Total horizontal inset for bottom content area (HomeView). Content width = screen - 2 * this.
        static let bottomContentHorizontalInset: CGFloat = 42.0
        static let bottomNavInternalSpacing: CGFloat = 16.0 // Spacing between bottom nav items
        static let timerIconSpacing: CGFloat = 8.0 // Spacing between circle icon and timer text
        /// Horizontal inset for bottom sheet content (ScreenLightView menu card). Same semantic as bottom content area.
        static let bottomSheetContentHorizontalInset: CGFloat = 42.0
    }
    
    // MARK: - Icon Sizes (Device-Specific)
    struct IconSize {
        static let battery: CGFloat = 16.0 // Battery icon height
        static let batteryWidth: CGFloat = 11.0 // Battery icon width
        static let menu: CGFloat = 32.0 // Menu icon size
        static let premium: CGFloat = 24.0 // Premium/crown icon size
        static let timerCircle: CGFloat = 24.0 // Timer circle icon size
        static let bottomIcon: CGFloat = 56.0 // Bottom nav icons (clock, phone)
        static let sosButton: CGFloat = 80.0 // SOS button size
        static let sosControlButton: CGFloat = 40.0 // Plus/minus button size
        static let powerButton: CGFloat = 120.0 // Power button size
        static let brightness: CGFloat = 20.0 // Brightness icon size (max / right)
        static let brightnessMin: CGFloat = 16.0 // Left (minimum) brightness icon - smaller per Figma
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let springResponse: Double = 0.6
        static let springDamping: Double = 0.8
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let flashlightIntensity = "flashlightIntensity"
        static let screenLightColorIndex = "screenLightColorIndex"
        static let screenLightBrightness = "screenLightBrightness"
        static let hasSeenScreenLightInstruction = "hasSeenScreenLightInstruction"
        static let savedScreenLightTimerDuration = "savedScreenLightTimerDuration"
    }
}
