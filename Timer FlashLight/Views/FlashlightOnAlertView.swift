//
//  FlashlightOnAlertView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

/// Alert shown when user turns on the flashlight. Full-screen dimmed overlay + centered card
/// with message, "Don't show again" with checkmark on left, and OK.
struct FlashlightOnAlertView: View {
    @Binding var dontShowAgain: Bool
    let onOK: () -> Void

    private static let message = "To keep the flashlight on, don't press the lock button or send the app to background. Set a timer — the app will auto-close after the timer ends."
    private static let dontShowAgainLabel = "Don't show this message again."
    private static let cardCornerRadius: CGFloat = 20

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .allowsHitTesting(true)

            VStack(spacing: AppTheme.Spacing.lg) {
                Text(Self.message)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.xl)

                // Checkmark on left, message on right (tappable row)
                Button(action: { dontShowAgain.toggle() }) {
                    HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
                        Group {
                            if dontShowAgain {
                                Image("ic_checkbox_checked")
                                    .resizable()
                                    .renderingMode(.original)
                            } else {
                                Image("ic_checkbox")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(AppTheme.Colors.textMuted)
                            }
                        }
                        .frame(width: 22, height: 22)
                        .accessibilityLabel(dontShowAgain ? "Checked" : "Unchecked")
                        Text(Self.dontShowAgainLabel)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
                .buttonStyle(.plain)

                Button(action: onOK) {
                    Text("OK")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.success)
                        .cornerRadius(AppTheme.CornerRadius.medium)
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
        FlashlightOnAlertView(dontShowAgain: .constant(false), onOK: {})
    }
}
