//
//  HomeViewModel.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI
import UIKit

/// ViewModel for the home/main screen
/// Manages timer, flashlight, and UI state
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isFlashlightOn: Bool = false
    @Published var timerDuration: TimeInterval = 0
    @Published var timerRemaining: TimeInterval = 0
    @Published var isTimerRunning: Bool = false
    @Published var savedTimerDuration: TimeInterval = 5 * 60 // 5 minutes (300 seconds)
    @Published var showZoomControls: Bool = false
    @Published var zoomLevel: Double = 1.0 // 1X, 2X, etc.
    @Published var batteryLevel: Double = 0.0 // Device battery level (0.0 to 1.0)
    @Published var sparkOpacity: Double = 0.0 // Spark brightness animation (0.0 = dim, 1.0 = bright)
    @Published var flashlightIntensity: Double = 1.0 // Flashlight intensity (0.0 to 1.0) - app-only value
    
    // MARK: - Toast Properties
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    // MARK: - Bottom Sheet Properties
    
    @Published var showTimerBottomSheet: Bool = false
    
    // MARK: - SOS Properties
    
    @Published var isSOSOn: Bool = false
    @Published var sosSpeed: SOSSpeed = .oneX // 1X, 1.5X, 2X
    @Published var isSOSFlashing: Bool = false // For blink animation
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var sosBlinkTimer: Timer?
    private var batteryRefreshTimer: Timer?
    private let timerService: TimerService
    private let flashlightService: FlashlightService
    
    private static let batteryRefreshInterval: TimeInterval = 60.0 // Fallback when notifications are delayed
    
    // MARK: - SOS Speed Enum
    
    enum SOSSpeed: Double, CaseIterable {
        case oneX = 1.0
        case onePointFiveX = 1.5
        case twoX = 2.0
        
        var displayText: String {
            switch self {
            case .oneX: return "1X"
            case .onePointFiveX: return "1.5X"
            case .twoX: return "2X"
            }
        }
        
        var blinkInterval: TimeInterval {
            switch self {
            case .oneX: return 1.0 // 1 blink per second
            case .onePointFiveX: return 0.75 // 2 blinks per 1.5 seconds = 1 blink per 0.75 seconds
            case .twoX: return 0.5 // 2 blinks per second = 1 blink per 0.5 seconds
            }
        }
        
        var nextSpeed: SOSSpeed? {
            switch self {
            case .oneX: return .onePointFiveX
            case .onePointFiveX: return .twoX
            case .twoX: return nil
            }
        }
        
        var previousSpeed: SOSSpeed? {
            switch self {
            case .oneX: return nil
            case .onePointFiveX: return .oneX
            case .twoX: return .onePointFiveX
            }
        }
    }
    
    // MARK: - Initialization
    
    init(timerService: TimerService = TimerService(), flashlightService: FlashlightService = FlashlightService()) {
        self.timerService = timerService
        self.flashlightService = flashlightService
        
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Get initial battery level
        updateBatteryLevel()
        
        // Observe battery level changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        // Observe battery state changes (charging/unplugged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        // Periodic refresh fallback - iOS battery notifications can be delayed or missed
        batteryRefreshTimer = Timer.scheduledTimer(withTimeInterval: Self.batteryRefreshInterval, repeats: true) { [weak self] _ in
            self?.updateBatteryLevel()
        }
        RunLoop.main.add(batteryRefreshTimer!, forMode: .common)
        
        // Load flashlight intensity from UserDefaults or device
        loadFlashlightIntensity()
    }
    
    @objc private func batteryLevelDidChange() {
        updateBatteryLevel()
    }
    
    /// Call when app becomes active to refresh battery level (e.g. returning from background)
    func refreshBatteryLevel() {
        updateBatteryLevel()
    }
    
    private func updateBatteryLevel() {
        let level = UIDevice.current.batteryLevel
        // batteryLevel is -1.0 if battery monitoring is not available
        let clamped = Double(max(0.0, min(1.0, level == -1.0 ? 0 : level)))
        DispatchQueue.main.async { [weak self] in
            self?.batteryLevel = clamped
        }
    }
    
    // MARK: - Timer Methods
    
    func startTimer(duration: TimeInterval) {
        // Don't allow timer when SOS is on or flashlight is off
        guard !isSOSOn else { return }
        guard isFlashlightOn else {
            showToastMessage("Turn on flashlight first")
            return
        }
        
        timerDuration = duration
        timerRemaining = duration
        isTimerRunning = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timerRemaining > 0 {
                self.timerRemaining -= 1
            } else {
                self.stopTimer()
                // Turn off power when timer ends
                self.turnOffFlashlight()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timerRemaining = 0
        timerDuration = 0
    }
    
    func useSavedTimer() {
        // Don't allow timer when SOS is on
        guard !isSOSOn else { return }
        // Check if flashlight is on
        guard isFlashlightOn else {
            showToastMessage("Turn on flashlight first")
            return
        }
        startTimer(duration: savedTimerDuration)
    }
    
    /// Sets a timer with the given duration and starts it immediately (if flashlight is on and SOS is off)
    /// If a timer is already running, it will be replaced with the new one and started from the beginning
    func setTimer(duration: TimeInterval) {
        // Update saved timer duration
        savedTimerDuration = duration
        
        // Stop any running timer before starting new one
        if isTimerRunning {
            stopTimer()
        }
        
        // Start the timer immediately when setting (if flashlight is on and SOS is off)
        if isFlashlightOn && !isSOSOn {
            startTimer(duration: duration)
        }
    }
    
    // MARK: - Flashlight Methods
    
    func toggleFlashlight() {
        // Show toast if SOS is on
        if isSOSOn {
            showToastMessage("Turn off SOS first")
            return
        }
        
        isFlashlightOn.toggle()
        
        if isFlashlightOn {
            // Always use our saved intensity value (which was initialized from system on first launch)
            flashlightService.turnOn(intensity: Float(flashlightIntensity))
            
            // Animate spark brightening up - smooth fade in (longer duration)
            withAnimation(.easeOut(duration: 0.8)) {
                sparkOpacity = 1.0
            }
        } else {
            flashlightService.turnOff()
            // Animate spark dimming off - smooth fade out (longer duration)
            withAnimation(.easeIn(duration: 0.7)) {
                sparkOpacity = 0.0
            }
            // Stop timer if running
            if isTimerRunning {
                stopTimer()
            }
        }
    }
    
    /// Update flashlight intensity
    /// - Parameter intensity: Intensity value from 0.0 to 1.0
    func setFlashlightIntensity(_ intensity: Double) {
        // Clamp intensity between 0.0 and 1.0
        flashlightIntensity = max(0.0, min(1.0, intensity))
        
        // Save to UserDefaults (app-only, doesn't affect device system settings)
        UserDefaults.standard.set(flashlightIntensity, forKey: AppConstants.UserDefaultsKeys.flashlightIntensity)
        
        // If flashlight is on, update the intensity immediately
        if isFlashlightOn {
            flashlightService.turnOn(intensity: Float(flashlightIntensity))
        }
    }
    
    /// Load flashlight intensity from UserDefaults
    /// Default to 1.0 on first launch, save user changes for future use
    private func loadFlashlightIntensity() {
        // Check if we have a saved value in UserDefaults
        if UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.flashlightIntensity) != nil {
            // Use saved value from UserDefaults
            flashlightIntensity = UserDefaults.standard.double(forKey: AppConstants.UserDefaultsKeys.flashlightIntensity)
            // Ensure it's in valid range
            flashlightIntensity = max(0.0, min(1.0, flashlightIntensity))
        } else {
            // First time: Default to 1.0 (100%)
            flashlightIntensity = 1.0
            // Save the default value to UserDefaults
            UserDefaults.standard.set(flashlightIntensity, forKey: AppConstants.UserDefaultsKeys.flashlightIntensity)
        }
    }
    
    func turnOffFlashlight() {
        isFlashlightOn = false
        flashlightService.turnOff()
        // Animate spark dimming off - smooth fade out (longer duration)
        withAnimation(.easeIn(duration: 0.7)) {
            sparkOpacity = 0.0
        }
        // Stop timer if running
        if isTimerRunning {
            stopTimer()
        }
    }
    
    // MARK: - Toast Methods
    
    func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Auto-hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showToast = false
        }
    }
    
    // MARK: - Zoom Methods
    
    func toggleZoomControls() {
        showZoomControls.toggle()
    }
    
    func increaseZoom() {
        zoomLevel = min(zoomLevel + 1.0, 5.0)
    }
    
    func decreaseZoom() {
        zoomLevel = max(zoomLevel - 1.0, 1.0)
    }
    
    // MARK: - Helper Methods
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            // Show HH:MM:SS Hr format when hours are set
            return String(format: "%02d:%02d:%02d Hr", hours, minutes, secs)
        } else if minutes > 0 {
            // Show MM:SS Min format for minutes
            return String(format: "%02d:%02d Min", minutes, secs)
        } else {
            // Show SS Sec format for seconds only
            return String(format: "%02d Sec", secs)
        }
    }
    
    // MARK: - Battery Formatting
    
    func formatBatteryPercentage() -> String {
        let percentage = batteryLevel * 100
        // Use standard rounding to match system battery display (e.g. 99.4% → 99%, 99.6% → 100%)
        return "\(Int(round(percentage)))%"
    }
    
    func formatTimeShort(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    // MARK: - SOS Methods
    
    func toggleSOS() {
        // If power is on, turn it off first
        if isFlashlightOn {
            turnOffFlashlight()
        }
        
        isSOSOn.toggle()
        
        if isSOSOn {
            startSOSBlinking()
            // Stop regular timer if running
            if isTimerRunning {
                stopTimer()
            }
        } else {
            stopSOSBlinking()
        }
    }
    
    // MARK: - Timer Progress
    
    var timerProgress: Double {
        guard timerDuration > 0 else { return 1.0 }
        return timerRemaining / timerDuration
    }
    
    func increaseSOSSpeed() {
        guard let nextSpeed = sosSpeed.nextSpeed else { return }
        sosSpeed = nextSpeed
        // Restart blinking with new speed
        if isSOSOn {
            stopSOSBlinking()
            startSOSBlinking()
        }
    }
    
    func decreaseSOSSpeed() {
        guard let previousSpeed = sosSpeed.previousSpeed else { return }
        sosSpeed = previousSpeed
        // Restart blinking with new speed
        if isSOSOn {
            stopSOSBlinking()
            startSOSBlinking()
        }
    }
    
    private func startSOSBlinking() {
        stopSOSBlinking() // Ensure no existing timer
        
        // Turn off regular flashlight if on
        if isFlashlightOn {
            isFlashlightOn = false
            flashlightService.turnOff()
        }
        
        let interval = sosSpeed.blinkInterval
        sosBlinkTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Toggle actual device flashlight
            self.isSOSFlashing.toggle()
            if self.isSOSFlashing {
                self.flashlightService.turnOn()
            } else {
                self.flashlightService.turnOff()
            }
        }
        
        // Start with flash on
        isSOSFlashing = true
        flashlightService.turnOn()
    }
    
    private func stopSOSBlinking() {
        sosBlinkTimer?.invalidate()
        sosBlinkTimer = nil
        isSOSFlashing = false
        flashlightService.turnOff()
    }
    
    var canIncreaseSOSSpeed: Bool {
        return sosSpeed.nextSpeed != nil
    }
    
    var canDecreaseSOSSpeed: Bool {
        return sosSpeed.previousSpeed != nil
    }
    
    // MARK: - Deinitializer
    
    deinit {
        timer?.invalidate()
        sosBlinkTimer?.invalidate()
        batteryRefreshTimer?.invalidate()
        
        // Remove battery monitoring observers
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }
}
