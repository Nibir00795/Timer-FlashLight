//
//  AppState.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation

/// Represents the overall state of the application
struct AppState {
    var isFlashlightEnabled: Bool = false
    var timerDuration: TimeInterval = AppConstants.Timer.defaultDuration
}
