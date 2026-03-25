//
//  PremiumSheetPresenter.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation

/// Presents the Access Premium paywall from Home (Upgrade button) or More (Upgrade on card).
/// Also presents the "This is a premium feature" alert (with Upgrade button) before paywall when needed.
final class PremiumSheetPresenter: ObservableObject {
    @Published var showPremiumSheet: Bool = false
    /// When true, show the premium feature alert (message + Upgrade button). Upgrade opens paywall.
    @Published var showPremiumFeatureAlert: Bool = false

    /// When paywall was opened after dismissing the Home timer sheet (Custom tap), set to true so that when user cancels paywall we reopen the timer sheet.
    var pendingReopenHomeTimerSheetOnPaywallDismiss: Bool = false
    /// Set by HomeView. Called when paywall is dismissed and pendingReopenHomeTimerSheetOnPaywallDismiss is true.
    var reopenHomeTimerSheet: (() -> Void)?
}
