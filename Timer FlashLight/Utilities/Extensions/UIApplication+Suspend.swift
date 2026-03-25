//
//  UIApplication+Suspend.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import UIKit

extension UIApplication {

    /// Sends the app to background (suspend). Used when timer completes so the app is no longer in foreground.
    /// Note: Uses a selector that may be reviewed by App Review; if rejected, consider an alternative (e.g. dismiss to home only).
    func sendToBackground() {
        let selector = Selector(("suspend"))
        guard responds(to: selector) else { return }
        perform(selector)
    }
}
