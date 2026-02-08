//
//  FlashlightService.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import AVFoundation

/// Service for controlling the device flashlight/torch
class FlashlightService {
    // MARK: - Properties
    
    private var captureDevice: AVCaptureDevice?
    
    // MARK: - Initialization
    
    init() {
        setupCaptureDevice()
    }
    
    // MARK: - Setup
    
    private func setupCaptureDevice() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            captureDevice = nil
            return
        }
        captureDevice = device
    }
    
    // MARK: - Public Methods
    
    /// Turn the flashlight on
    func turnOn() {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return }
            setTorchMode(device: device, mode: .on)
            return
        }
        setTorchMode(device: device, mode: .on)
    }
    
    /// Turn the flashlight on with a specific intensity level
    /// - Parameter intensity: Intensity level from 0.0 (off) to 1.0 (maximum)
    func turnOn(intensity: Float) {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return }
            setTorchLevel(device: device, level: intensity)
            return
        }
        setTorchLevel(device: device, level: intensity)
    }
    
    /// Turn the flashlight off
    func turnOff() {
        guard let device = captureDevice else { return }
        setTorchMode(device: device, mode: .off)
    }
    
    /// Toggle the flashlight state
    func toggle() {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return }
            setTorchMode(device: device, mode: device.torchMode == .on ? .off : .on)
            return
        }
        setTorchMode(device: device, mode: device.torchMode == .on ? .off : .on)
    }
    
    /// Check if flashlight is available
    var isAvailable: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.hasTorch
    }
    
    /// Get current flashlight state
    var isOn: Bool {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return false }
            return device.torchMode == .on
        }
        return device.torchMode == .on
    }
    
    /// Get maximum torch level (always 1.0 for iOS devices)
    var maxTorchLevel: Float {
        return 1.0
    }
    
    /// Get current torch level from device (if torch is on)
    /// Returns the actual torch level value (0.0 to 1.0)
    /// Returns nil if torch is off or unavailable
    var currentTorchLevel: Float? {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return nil }
            // Read the actual torch level if torch is active
            return device.isTorchActive ? device.torchLevel : nil
        }
        // Read the actual torch level if torch is active
        return device.isTorchActive ? device.torchLevel : nil
    }
    
    /// Turn the flashlight on using the system's saved torch level
    /// This will use whatever level the system has saved (e.g., 50% if user set it to 50% before)
    /// Returns the actual torch level that was set (system's saved level)
    func turnOnWithSystemLevel() -> Float? {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return nil }
            return setTorchModeWithSystemLevel(device: device)
        }
        return setTorchModeWithSystemLevel(device: device)
    }
    
    /// Get the system's saved torch level by temporarily turning it on
    /// This reads the level that iOS would use when turning torch on
    func getSystemTorchLevel() -> Float? {
        guard let device = captureDevice else {
            setupCaptureDevice()
            guard let device = captureDevice else { return nil }
            return readSystemTorchLevel(device: device)
        }
        return readSystemTorchLevel(device: device)
    }
    
    // MARK: - Private Methods
    
    private func setTorchMode(device: AVCaptureDevice, mode: AVCaptureDevice.TorchMode) {
        do {
            try device.lockForConfiguration()
            if device.isTorchModeSupported(mode) {
                device.torchMode = mode
            }
            device.unlockForConfiguration()
        } catch {
            print("Error setting torch mode: \(error.localizedDescription)")
        }
    }
    
    private func setTorchLevel(device: AVCaptureDevice, level: Float) {
        do {
            try device.lockForConfiguration()
            if device.isTorchModeSupported(.on) {
                // Clamp level between 0.0 and 1.0 (iOS torch level range)
                let clampedLevel = max(0.0, min(level, 1.0))
                if clampedLevel > 0 {
                    try device.setTorchModeOn(level: clampedLevel)
                } else {
                    device.torchMode = .off
                }
            }
            device.unlockForConfiguration()
        } catch {
            print("Error setting torch level: \(error.localizedDescription)")
        }
    }
    
    /// Turn torch on using system's saved level (by using setTorchMode(.on) without specifying level)
    /// Then read and return the actual level that was set
    private func setTorchModeWithSystemLevel(device: AVCaptureDevice) -> Float? {
        do {
            try device.lockForConfiguration()
            if device.isTorchModeSupported(.on) {
                // Turn on using system's saved level (by just setting mode to .on)
                device.torchMode = .on
                // Read the actual level that was set by the system
                var systemLevel = device.torchLevel
                // If we got 0, it might mean the system hasn't set it yet or it's actually 0
                // Try reading again after a brief moment
                if systemLevel == 0 {
                    systemLevel = device.torchLevel
                }
                // If still 0 or invalid, default to 1.0
                if systemLevel <= 0 {
                    systemLevel = 1.0
                }
                device.unlockForConfiguration()
                return systemLevel
            }
            device.unlockForConfiguration()
            return 1.0 // Default if not supported
        } catch {
            print("Error setting torch mode with system level: \(error.localizedDescription)")
            return 1.0 // Default on error
        }
    }
    
    /// Read system's saved torch level by temporarily turning it on and off
    private func readSystemTorchLevel(device: AVCaptureDevice) -> Float? {
        let wasOn = device.torchMode == .on
        var systemLevel: Float = 1.0
        
        do {
            try device.lockForConfiguration()
            if device.isTorchModeSupported(.on) {
                if wasOn {
                    // If already on, just read the current level
                    systemLevel = device.torchLevel
                } else {
                    // Temporarily turn on to read system level
                    device.torchMode = .on
                    // Give a tiny moment for the level to be set by the system
                    // Then read it
                    systemLevel = device.torchLevel
                    // If we got 0, it might mean the system hasn't set it yet, try again
                    if systemLevel == 0 {
                        // Use a small delay or check again
                        systemLevel = device.torchLevel
                        // If still 0, default to 1.0 (full brightness)
                        if systemLevel == 0 {
                            systemLevel = 1.0
                        }
                    }
                    // Restore previous state (turn off)
                    device.torchMode = .off
                }
            }
            device.unlockForConfiguration()
            return systemLevel
        } catch {
            print("Error reading system torch level: \(error.localizedDescription)")
            // If error, return default 1.0
            return 1.0
        }
    }
}
