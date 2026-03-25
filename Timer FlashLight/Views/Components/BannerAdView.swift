//
//  BannerAdView.swift
//  Timer FlashLight
//
//  AdMob banner ad wrapper for SwiftUI.
//

import SwiftUI
import GoogleMobileAds

/// SwiftUI wrapper for AdMob banner. Displays a banner ad (320x50).
struct BannerAdView: UIViewControllerRepresentable {
    let adUnitID: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        viewController.view.isOpaque = false
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.backgroundColor = .clear
        bannerView.isOpaque = false
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
        ])
        bannerView.load(Request())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
