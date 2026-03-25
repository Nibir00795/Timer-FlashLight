//
//  Timer_FlashLightApp.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit
import GoogleMobileAds

@main
struct Timer_FlashLightApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        // Check fonts on app launch (only in debug)
        #if DEBUG
        FontChecker.checkFonts()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                UIApplication.shared.isIdleTimerDisabled = true
            case .inactive:
                UIApplication.shared.isIdleTimerDisabled = true
                // Restore system brightness as soon as app leaves active (user home/swipe). iOS may suspend before .background.
                ScreenLightBrightnessStore.restoreBrightnessIfNeeded()
            case .background:
                UIApplication.shared.isIdleTimerDisabled = false
                ScreenLightBrightnessStore.restoreBrightnessIfNeeded()
            @unknown default:
                break
            }
        }
    }
}
