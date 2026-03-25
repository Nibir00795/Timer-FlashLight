//
//  ScreenLightViewModel.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import Combine
import UIKit
import SwiftUI

/// ViewModel for the screen light/color view
/// Manages color presets, timer, brightness, and state persistence
class ScreenLightViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentColorIndex: Int = 0
    @Published var showInstructionSheet: Bool = false
    @Published var showMenuCard: Bool = false
    @Published var screenLightTimerRemaining: TimeInterval = 0
    @Published var screenLightTimerDuration: TimeInterval = 0
    @Published var isScreenLightTimerRunning: Bool = false
    @Published var savedScreenLightTimerDuration: TimeInterval = 5 * 60 // 5 minutes default
    @Published var screenLightBrightness: Double = 1.0
    @Published var showTimerBottomSheet: Bool = false
    @Published var showMenuBottomSheet: Bool = false
    @Published var pendingTimerSheet: Bool = false // Flag to open timer sheet after menu dismisses
    @Published var pendingMenuCard: Bool = false // Flag to open menu card after timer sheet dismisses
    @Published var timerCompleted: Bool = false // Flag to indicate timer completion
    /// When true, timer sheet was dismissed to show premium alert — do not reopen menu when timer sheet closes.
    var dismissedTimerSheetForPremiumAlert: Bool = false
    /// When true, reopen timer sheet when paywall (or alert) is dismissed (e.g. user cancelled from Custom tap flow).
    var reopenTimerSheetWhenPaywallDismissed: Bool = false

    // MARK: - Color Presets
    
    static let colorPresets: [String] = [
        "#FFFFFF", // White (default first-time)
        "#07B151", // Green
        "#D52127", // Red
        "#2FBBB3", // Teal
        "#F36621", // Orange
        "#2357BC", // Blue
        "#F6851E", // Orange-Yellow
        "#54D5C4", // Cyan
        "#4C489B", // Purple
        "#733B97", // Purple
        "#FBB40F", // Yellow
        "#AF3A94"  // Magenta
    ]
    
    var currentColor: Color {
        Color(hex: Self.colorPresets[currentColorIndex])
    }
    
    // MARK: - Private Properties
    
    private var screenLightTimer: Timer?
    private let brightnessService: BrightnessService
    private var systemBrightness: Double = 1.0 // Original system brightness to restore
    
    // MARK: - Initialization
    
    init(brightnessService: BrightnessService = BrightnessService()) {
        self.brightnessService = brightnessService
        loadState()
    }
    
    // MARK: - State Management
    
    func loadState() {
        // Load saved color index (default: 0 for white)
        if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.screenLightColorIndex) != nil {
            currentColorIndex = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.screenLightColorIndex)
            // Ensure valid range
            currentColorIndex = max(0, min(Self.colorPresets.count - 1, currentColorIndex))
        } else {
            currentColorIndex = 0 // White on first open
        }
        
        // Load saved brightness (default: current system brightness)
        if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.screenLightBrightness) != nil {
            screenLightBrightness = UserDefaults.standard.double(forKey: AppConstants.UserDefaultsKeys.screenLightBrightness)
            screenLightBrightness = max(0.0, min(1.0, screenLightBrightness))
        } else {
            // First time: use current system brightness
            screenLightBrightness = brightnessService.getSystemBrightness()
        }
        
        // Load saved timer duration
        if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.savedScreenLightTimerDuration) != nil {
            savedScreenLightTimerDuration = UserDefaults.standard.double(forKey: AppConstants.UserDefaultsKeys.savedScreenLightTimerDuration)
        }
        
        // Check if instruction sheet was shown
        let hasSeenInstruction = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hasSeenScreenLightInstruction)
        showInstructionSheet = !hasSeenInstruction
    }
    
    func saveState() {
        UserDefaults.standard.set(currentColorIndex, forKey: AppConstants.UserDefaultsKeys.screenLightColorIndex)
        UserDefaults.standard.set(screenLightBrightness, forKey: AppConstants.UserDefaultsKeys.screenLightBrightness)
        UserDefaults.standard.set(savedScreenLightTimerDuration, forKey: AppConstants.UserDefaultsKeys.savedScreenLightTimerDuration)
    }
    
    func saveSystemBrightness() {
        systemBrightness = brightnessService.getSystemBrightness()
    }

    /// Saved system brightness to restore when leaving Screen Light or when app goes to background.
    var savedSystemBrightnessForRestore: Double { systemBrightness }

    func restoreSystemBrightness() {
        brightnessService.setSystemBrightness(systemBrightness)
    }
    
    // MARK: - Color Management
    
    enum SwipeDirection {
        case left
        case right
    }
    
    /// - Parameters:
    ///   - direction: Swipe direction (left = next color, right = previous).
    ///   - isPremium: If false, only indices 0..<freeColorCount are allowed; going past calls onLimitReached.
    ///   - onLimitReached: Called when a free user tries to swipe past the free color limit (short paywall trigger).
    func changeColor(direction: SwipeDirection, isPremium: Bool = true, onLimitReached: (() -> Void)? = nil) {
        guard !showInstructionSheet else { return } // Block if instruction sheet is showing

        let count = Self.colorPresets.count
        let nextIndex: Int
        switch direction {
        case .left:
            nextIndex = (currentColorIndex + 1) % count
        case .right:
            nextIndex = (currentColorIndex - 1 + count) % count
        }

        if !isPremium && nextIndex >= AppConstants.Premium.freeColorCount {
            onLimitReached?()
            return
        }

        currentColorIndex = nextIndex

        // Save color state immediately
        UserDefaults.standard.set(currentColorIndex, forKey: AppConstants.UserDefaultsKeys.screenLightColorIndex)
    }
    
    // MARK: - Instruction Sheet
    
    func dismissInstructionSheet() {
        showInstructionSheet = false
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasSeenScreenLightInstruction)
        showMenuCard = true
        showMenuBottomSheet = true
    }

    // MARK: - Menu Card
    
    /// Toggle menu bottom sheet: tap on background shows sheet when hidden, hides sheet when visible. No auto-close.
    func toggleMenuCard() {
        guard !showInstructionSheet else { return }
        
        showMenuBottomSheet.toggle()
        showMenuCard = showMenuBottomSheet
    }
    
    // MARK: - Timer Methods

    /// Called when Screen Light timer starts so the app can stop the other (Home) timer. Only one timer active at a time.
    var onScreenLightTimerDidStart: (() -> Void)?

    func startScreenLightTimer(duration: TimeInterval) {
        onScreenLightTimerDidStart?()
        screenLightTimerDuration = duration
        screenLightTimerRemaining = duration
        isScreenLightTimerRunning = true

        screenLightTimer?.invalidate()
        timerCompleted = false // Reset completion flag
        screenLightTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.screenLightTimerRemaining > 0 {
                self.screenLightTimerRemaining -= 1
            } else {
                // Timer reached zero - mark as completed before stopping
                self.timerCompleted = true
                self.stopScreenLightTimer()
            }
        }
        
    }
    
    func stopScreenLightTimer() {
        screenLightTimer?.invalidate()
        screenLightTimer = nil
        isScreenLightTimerRunning = false
        screenLightTimerRemaining = 0
        // Don't reset screenLightTimerDuration here - keep it for completion check
        // Only reset if manually stopped (not completed)
        if !timerCompleted {
            screenLightTimerDuration = 0
        }
    }
    
    func useSavedScreenLightTimer() {
        startScreenLightTimer(duration: savedScreenLightTimerDuration)
    }
    
    /// Sets timer duration and starts it immediately (same as HomeView setTimer).
    func setScreenLightTimer(duration: TimeInterval) {
        savedScreenLightTimerDuration = duration
        UserDefaults.standard.set(duration, forKey: AppConstants.UserDefaultsKeys.savedScreenLightTimerDuration)
        
        if isScreenLightTimerRunning {
            stopScreenLightTimer()
        }
        startScreenLightTimer(duration: duration)
    }
    
    // MARK: - Brightness Methods
    
    /// Applies the current screenLightBrightness to the device. Use when entering screen light view
    /// so the physical brightness matches the slider even if the value did not "change".
    func applyCurrentBrightnessToSystem() {
        brightnessService.setSystemBrightness(screenLightBrightness)
    }
    
    func setScreenLightBrightness(_ brightness: Double) {
        let clampedBrightness = max(0.0, min(1.0, brightness))
        
        // Only update if value actually changed to avoid unnecessary updates
        guard abs(screenLightBrightness - clampedBrightness) > 0.001 else { return }
        
        screenLightBrightness = clampedBrightness
        
        // Update device brightness immediately
        brightnessService.setSystemBrightness(clampedBrightness)
        
        // Save to UserDefaults
        UserDefaults.standard.set(clampedBrightness, forKey: AppConstants.UserDefaultsKeys.screenLightBrightness)
    }
    
    // MARK: - Helper Methods
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d Hr", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%02d:%02d Min", minutes, secs)
        } else {
            return String(format: "%02d Sec", secs)
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        screenLightTimer?.invalidate()
    }
}
