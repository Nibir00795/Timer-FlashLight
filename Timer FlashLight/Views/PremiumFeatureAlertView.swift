//
//  PremiumFeatureAlertView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

/// Alert shown when a free user tries to use a premium feature (Custom timer, Auto-Flash, colour swipe limit).
/// Matches FlashlightOnAlertView / Screen Light instruction style: dimmed overlay + centered card + crown + Cancel + Upgrade.
struct PremiumFeatureAlertView: View {
    @Binding var isPresented: Bool
    /// Called when user taps Upgrade: dismiss alert and open paywall.
    var onUpgrade: () -> Void
    /// Called when user taps Cancel: dismiss alert only. Optional (e.g. Screen Light reopens timer sheet).
    var onCancel: (() -> Void)? = nil

    private static let message = "This is a premium feature."
    private static let cardCornerRadius: CGFloat = 20
    private static let crownSize: CGFloat = 40

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .allowsHitTesting(true)

            VStack(spacing: AppTheme.Spacing.lg) {
                Image("ic_crown")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: Self.crownSize, height: Self.crownSize)
                    .padding(.top, AppTheme.Spacing.xl)

                Text(Self.message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppTheme.Spacing.xl)

                HStack(spacing: AppTheme.Spacing.sm) {
                    Button(action: {
                        isPresented = false
                        onCancel?()
                    }) {
                        Text("Cancel")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                    }

                    Button(action: {
                        isPresented = false
                        onUpgrade()
                    }) {
                        Text("Upgrade")
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.success)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .background(AppTheme.Colors.bottomSheetBackground)
            .clipShape(RoundedRectangle(cornerRadius: Self.cardCornerRadius, style: .continuous))
            .padding(.horizontal, AppTheme.Spacing.xl)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? AppConstants.Layout.maxContentWidthIPad : nil)
        }
        .allowsHitTesting(true)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        PremiumFeatureAlertView(isPresented: .constant(true), onUpgrade: {})
    }
}
