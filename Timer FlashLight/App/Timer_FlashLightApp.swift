//
//  Timer_FlashLightApp.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

@main
struct Timer_FlashLightApp: App {
    init() {
        // Check fonts on app launch (only in debug)
        #if DEBUG
        FontChecker.checkFonts()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
