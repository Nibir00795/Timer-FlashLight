//
//  BrightnessService.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import UIKit

/// Service for managing device screen brightness
class BrightnessService {
    /// Get the current system brightness level
    /// - Returns: Brightness value from 0.0 to 1.0
    func getSystemBrightness() -> Double {
        return Double(UIScreen.main.brightness)
    }
    
    /// Set the device screen brightness
    /// - Parameter brightness: Brightness value from 0.0 to 1.0
    func setSystemBrightness(_ brightness: Double) {
        let clampedBrightness = max(0.0, min(1.0, brightness))
        UIScreen.main.brightness = CGFloat(clampedBrightness)
    }
}
