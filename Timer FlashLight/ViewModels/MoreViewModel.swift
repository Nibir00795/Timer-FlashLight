//
//  MoreViewModel.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import Combine
import UIKit

/// ViewModel for the More/Settings screen
class MoreViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: AppConstants.UserDefaultsKeys.notificationsEnabled)
        }
    }

    @Published var autoFlashOnStartup: Bool {
        didSet {
            UserDefaults.standard.set(autoFlashOnStartup, forKey: AppConstants.UserDefaultsKeys.autoFlashOnStartup)
        }
    }

    // MARK: - Initialization

    init() {
        self.notificationsEnabled = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.notificationsEnabled) as? Bool ?? true
        self.autoFlashOnStartup = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.autoFlashOnStartup) as? Bool ?? false
    }

    // MARK: - Public Methods

    func rateApp() {
        UIApplication.shared.open(AppConstants.AppStore.writeReviewURL)
    }

    func shareApp() {
        let url = AppConstants.AppStore.appURL
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else { return }
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        topVC.present(activityVC, animated: true)
    }

    func openTermsAndConditions() {
        UIApplication.shared.open(AppConstants.URLs.termsAndConditions)
    }

    func openPrivacyPolicy() {
        UIApplication.shared.open(AppConstants.URLs.privacyPolicy)
    }

    func openTableLamp() {
        UIApplication.shared.open(AppConstants.AppStore.tableLampURL)
    }

    func openRelaxingSound() {
        UIApplication.shared.open(AppConstants.AppStore.relaxingSoundURL)
    }

    func upgradeToPremium() {
        // Premium logic to be provided later
    }
}
