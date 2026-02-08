//
//  FontChecker.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit

/// Helper to check if custom fonts are loaded
struct FontChecker {
    /// Print all available font families and check for Saira and Sora
    static func checkFonts() {
        print("=== Available Font Families ===")
        let fontFamilies = UIFont.familyNames.sorted()
        
        for family in fontFamilies {
            print("Family: \(family)")
            let fonts = UIFont.fontNames(forFamilyName: family)
            for font in fonts {
                print("  - \(font)")
            }
        }
        
        print("\n=== Checking for Saira ===")
        if fontFamilies.contains("Saira") {
            print("✅ Saira font family found!")
            let sairaFonts = UIFont.fontNames(forFamilyName: "Saira")
            print("Saira fonts: \(sairaFonts)")
        } else {
            print("❌ Saira font family NOT found")
        }
        
        print("\n=== Checking for Sora ===")
        if fontFamilies.contains("Sora") {
            print("✅ Sora font family found!")
            let soraFonts = UIFont.fontNames(forFamilyName: "Sora")
            print("Sora fonts: \(soraFonts)")
        } else {
            print("❌ Sora font family NOT found")
        }
    }
    
    /// Test if a specific font can be loaded
    static func testFont(name: String, size: CGFloat = 16) -> Bool {
        if let font = UIFont(name: name, size: size) {
            print("✅ Font '\(name)' loaded successfully: \(font.fontName)")
            return true
        } else {
            print("❌ Font '\(name)' failed to load")
            return false
        }
    }
}
