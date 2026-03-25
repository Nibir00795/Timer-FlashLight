//
//  AppConstants.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import UIKit

struct AppConstants {
    /// True when running on iPad; used to scale layout, icons, and typography.
    static var isIPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    /// Scale factor for iPad (spacing, icon sizes, etc.). Phone = 1.0.
    static var ipadScale: CGFloat { isIPad ? 1.25 : 1.0 }

    // MARK: - Timer Constants
    struct Timer {
        static let defaultDuration: TimeInterval = 60.0
        static let minDuration: TimeInterval = 1.0
        static let maxDuration: TimeInterval = 3600.0
    }

    // MARK: - Premium / Free Limits
    struct Premium {
        /// Number of screen light colors available for free users (indices 0..<freeColorCount).
        static let freeColorCount: Int = 3
    }
    
    // MARK: - UI Constants (scaled on iPad)
    struct UI {
        static var cornerRadius: CGFloat { 12.0 * AppConstants.ipadScale }
        static var padding: CGFloat { 16.0 * AppConstants.ipadScale }
    }
    
    // MARK: - Layout Constants (Device-Specific Spacing; scaled on iPad)
    struct Layout {
        private static func s(_ value: CGFloat) -> CGFloat { value * AppConstants.ipadScale }
        // Top section (space below status bar / safe area top)
        static var upgradeButtonTopSpacing: CGFloat { s(28.0) }
        static var batteryLeftSpacing: CGFloat { s(40.0) }
        static var menuRightSpacing: CGFloat { s(40.0) }
        // SOS button
        static var sosButtonTopSpacing: CGFloat { s(46.0) }
        static var sosButtonSpacing: CGFloat { s(40.0) }
        // Bottom section
        static var bottomNavTopSpacing: CGFloat { s(80.0) }
        static var bottomNavHorizontalSpacing: CGFloat { s(40.0) }
        static var bottomNavContentInset: CGFloat { s(16.0) }
        static var bottomContentHorizontalInset: CGFloat { s(42.0) }
        static let maxContentWidthIPad: CGFloat = 430
        static var bottomNavInternalSpacing: CGFloat { s(16.0) }
        /// Tighter spacing between bottom nav icons on iPad to avoid excessive gap.
        static var bottomNavBetweenIconsSpacing: CGFloat { isIPad ? 12 : s(16.0) }
        static var timerIconSpacing: CGFloat { s(8.0) }
        static var bottomSheetContentHorizontalInset: CGFloat { s(42.0) }
    }
    
    // MARK: - Icon Sizes (Device-Specific; scaled on iPad)
    struct IconSize {
        private static func s(_ value: CGFloat) -> CGFloat { value * AppConstants.ipadScale }
        static var battery: CGFloat { s(16.0) }
        static var batteryWidth: CGFloat { s(11.0) }
        static var menu: CGFloat { s(32.0) }
        static var premium: CGFloat { s(24.0) }
        static var timerCircle: CGFloat { s(24.0) }
        static var bottomIcon: CGFloat { s(56.0) }
        static var sosButton: CGFloat { s(80.0) }
        static var sosControlButton: CGFloat { s(40.0) }
        static var powerButton: CGFloat { s(120.0) }
        static var brightness: CGFloat { s(20.0) }
        static var brightnessMin: CGFloat { s(16.0) }
        static var moreRowIcon: CGFloat { s(20.0) }
        static var moreGeneralIcon: CGFloat { s(18.0) }
        static var moreAppIcon: CGFloat { s(40.0) }
        static var moreBack: CGFloat { s(32.0) }
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let springResponse: Double = 0.6
        static let springDamping: Double = 0.8
    }
    
    // MARK: - AdMob IDs
    struct AdMob {
        /// Set to false when ready for production release. Also update Info.plist GADApplicationIdentifier to Prod.appId.
        static let useTestMode = true
        
        // Test IDs (Google sample ads - always fill, safe for development)
        struct Test {
            static let appId = "ca-app-pub-3940256099942544~1458002511"
            static let mainScreenBanner = "ca-app-pub-3940256099942544/2934735716"
            static let screenLightBanner = "ca-app-pub-3940256099942544/2934735716"
        }
        
        // Production IDs (switch useTestMode to false and update Info.plist GADApplicationIdentifier)
        struct Prod {
            static let appId = "ca-app-pub-2802390020564774~9692606155"
            static let mainScreenBanner = "ca-app-pub-2802390020564774/9636765838"
            static let screenLightBanner = "ca-app-pub-2802390020564774/8030780941"
        }
        
        static var appId: String { useTestMode ? Test.appId : Prod.appId }
        static var mainScreenBanner: String { useTestMode ? Test.mainScreenBanner : Prod.mainScreenBanner }
        static var screenLightBanner: String { useTestMode ? Test.screenLightBanner : Prod.screenLightBanner }
    }
    
    // MARK: - App Store & URLs
    struct AppStore {
        /// This app (Timer FlashLight)
        static let appId = "6757694374"
        static var appURL: URL { URL(string: "https://apps.apple.com/app/id\(appId)")! }
        static var writeReviewURL: URL { URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review")! }
        /// Other apps (More Apps section)
        static let tableLampAppId = "1561353163"
        static let relaxingSoundAppId = "6754354522"
        static var tableLampURL: URL { URL(string: "https://apps.apple.com/app/id\(tableLampAppId)")! }
        static var relaxingSoundURL: URL { URL(string: "https://apps.apple.com/app/id\(relaxingSoundAppId)")! }
    }

    struct URLs {
        static let termsAndConditions = URL(string: "https://example.com/terms")!
        static let privacyPolicy = URL(string: "https://example.com/privacy")!
    }

    // MARK: - In-App Purchase
    /// Replace with your App Store Connect product ID (e.g. non-consumable "Lifetime").
    struct IAP {
        static let premiumLifetimeProductID = "com.appswave.TimerFlashLight.premium.lifetime"
    }

    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let flashlightIntensity = "flashlightIntensity"
        static let dontShowFlashlightOnAlert = "dontShowFlashlightOnAlert"
        static let savedTimerDuration = "savedTimerDuration"
        static let screenLightColorIndex = "screenLightColorIndex"
        static let screenLightBrightness = "screenLightBrightness"
        static let hasSeenScreenLightInstruction = "hasSeenScreenLightInstruction"
        static let savedScreenLightTimerDuration = "savedScreenLightTimerDuration"
        static let notificationsEnabled = "notificationsEnabled"
        static let autoFlashOnStartup = "autoFlashOnStartup"
        static let isPremiumUnlocked = "isPremiumUnlocked"
    }
}
