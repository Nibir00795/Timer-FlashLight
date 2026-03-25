//
//  ScreenLightBrightnessStore.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation

/// Shared store so the App can restore system brightness when going to background
/// while Screen Light is showing (fullScreenCover may not receive scenePhase in time).
enum ScreenLightBrightnessStore {
    private static let lock = NSLock()
    private static var _savedSystemBrightness: Double = 0.5
    private static var _isScreenLightShowing: Bool = false

    static var savedSystemBrightness: Double {
        get { lock.withLock { _savedSystemBrightness } }
        set { lock.withLock { _savedSystemBrightness = newValue } }
    }

    static var isScreenLightShowing: Bool {
        get { lock.withLock { _isScreenLightShowing } }
        set { lock.withLock { _isScreenLightShowing = newValue } }
    }

    static func notifyScreenLightDidAppear(savedBrightness: Double) {
        lock.withLock {
            _savedSystemBrightness = savedBrightness
            _isScreenLightShowing = true
        }
    }

    static func notifyScreenLightDidDisappear() {
        lock.withLock { _isScreenLightShowing = false }
    }

    /// Call when app enters background. Restores system brightness if Screen Light was showing.
    static func restoreBrightnessIfNeeded() {
        let (shouldRestore, brightness) = lock.withLock { (_isScreenLightShowing, _savedSystemBrightness) }
        guard shouldRestore else { return }
        BrightnessService().setSystemBrightness(brightness)
    }
}
