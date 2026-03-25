//
//  ContentView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @StateObject private var premiumPresenter = PremiumSheetPresenter()
    @StateObject private var purchaseManager = PurchaseManager()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(onMenuTap: {
                navigationPath.append(AppRoute.more)
            })
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .more:
                    MoreView()
                }
            }
        }
        .environmentObject(premiumPresenter)
        .environmentObject(purchaseManager)
        .overlay {
            if premiumPresenter.showPremiumFeatureAlert {
                PremiumFeatureAlertView(
                    isPresented: Binding(
                        get: { premiumPresenter.showPremiumFeatureAlert },
                        set: { premiumPresenter.showPremiumFeatureAlert = $0 }
                    ),
                    onUpgrade: {
                        premiumPresenter.showPremiumFeatureAlert = false
                        premiumPresenter.showPremiumSheet = true
                    },
                    onCancel: {
                        premiumPresenter.pendingReopenHomeTimerSheetOnPaywallDismiss = false
                    }
                )
                .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: $premiumPresenter.showPremiumSheet) {
            AccessPremiumView(isPresented: $premiumPresenter.showPremiumSheet, purchaseManager: purchaseManager)
        }
        .onChange(of: premiumPresenter.showPremiumSheet) { isShowing in
            if !isShowing, premiumPresenter.pendingReopenHomeTimerSheetOnPaywallDismiss {
                premiumPresenter.pendingReopenHomeTimerSheetOnPaywallDismiss = false
                premiumPresenter.reopenHomeTimerSheet?()
            }
        }
    }
}

// MARK: - App Navigation Routes

private enum AppRoute: Hashable {
    case more
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(PremiumSheetPresenter())
        .environmentObject(PurchaseManager())
        .preferredColorScheme(.dark)
}
