//
//  MoreView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

/// More/Settings screen matching Figma design
struct MoreView: View {
    // MARK: - Properties

    @StateObject private var viewModel = MoreViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var premiumPresenter: PremiumSheetPresenter
    @EnvironmentObject private var purchaseManager: PurchaseManager

    // MARK: - Body

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    if !purchaseManager.isPremiumUnlocked {
                        accessPremiumCard
                    }
                    controlsSection
                    generalSection
                    moreAppsSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("More")
                    .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(20)))
                    .foregroundColor(AppTheme.Colors.textLight)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("ic_back")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.Colors.textLight)
                        .frame(width: AppConstants.IconSize.moreBack, height: AppConstants.IconSize.moreBack)
                        .accessibilityLabel("Back")
                        .accessibilityHint("Returns to previous screen")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Access Premium Card

    private var accessPremiumCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image("ic_crown")
                .resizable()
                .renderingMode(.original)
                .frame(width: AppConstants.IconSize.moreBack, height: AppConstants.IconSize.moreBack)
                .accessibilityLabel("Premium")

            VStack(alignment: .leading, spacing: 0) {
                Text("Access Premium")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(Color(hex: "E8E0EB"))
                Text("No Ads, Screen Colours, Custom Timer & more.")
                    .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(12)))
                    .foregroundColor(Color(hex: "A1A1A1"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { premiumPresenter.showPremiumSheet = true }) {
                Text("Upgrade")
                    .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(13)))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.success)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(37)
        }
        .padding(AppTheme.Spacing.md)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.cardBackground, Color(hex: "333333")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(AppConstants.UI.cornerRadius)
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            sectionHeader("Controls")

            // Notification row hidden for now. Auto-Flash is premium: free users see alert when toggling ON.
            moreRow(
                icon: "ic_light_on_startup",
                iconSize: AppConstants.IconSize.moreRowIcon,
                title: "Auto-Flash on Startup",
                showToggle: true,
                isOn: $viewModel.autoFlashOnStartup
            )
        }
        .onChange(of: viewModel.autoFlashOnStartup) { newValue in
            if newValue && !purchaseManager.isPremiumUnlocked {
                viewModel.autoFlashOnStartup = false
                premiumPresenter.showPremiumFeatureAlert = true
            }
        }
    }

    // MARK: - General Section

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            sectionHeader("General")

            moreRow(icon: "ic_rate_app", iconSize: AppConstants.IconSize.moreGeneralIcon, title: "Rate App") {
                viewModel.rateApp()
            }

            moreRow(icon: "ic_share_app", iconSize: AppConstants.IconSize.moreGeneralIcon, title: "Share") {
                viewModel.shareApp()
            }

            moreRow(icon: "ic_terms", iconSize: AppConstants.IconSize.moreGeneralIcon, title: "Terms & Conditions") {
                viewModel.openTermsAndConditions()
            }

            moreRow(icon: "ic_privacy", iconSize: AppConstants.IconSize.moreGeneralIcon, title: "Privacy Policy") {
                viewModel.openPrivacyPolicy()
            }
        }
    }

    // MARK: - More Apps Section

    private var moreAppsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            sectionHeader("More Apps")

            moreRow(
                icon: "ic_table_lamp",
                iconSize: AppConstants.IconSize.moreAppIcon,
                title: "Table Lamp",
                useOriginalRendering: true
            ) {
                viewModel.openTableLamp()
            }

            moreRow(
                icon: "ic_relaxing_sound",
                iconSize: AppConstants.IconSize.moreAppIcon,
                title: "Relaxing Sound",
                useOriginalRendering: true
            ) {
                viewModel.openRelaxingSound()
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.custom(AppTheme.Typography.soraFontName, size: AppTheme.Typography.scaledSize(14)))
            .foregroundColor(Color(hex: "B3B3B3"))
    }

    private func moreRow(
        icon: String,
        iconSize: CGFloat,
        title: String,
        showToggle: Bool = false,
        isOn: Binding<Bool>? = nil,
        useOriginalRendering: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Group {
                if useOriginalRendering {
                    Image(icon)
                        .resizable()
                        .renderingMode(.original)
                } else {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.Colors.textLight)
                }
            }
            .frame(width: iconSize, height: iconSize)
            .cornerRadius(useOriginalRendering ? 8 : 0)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textLight)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showToggle, let binding = isOn {
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .tint(AppTheme.Colors.success)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 17)
        .background(AppTheme.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Border.width)
        )
        .cornerRadius(AppTheme.CornerRadius.small)
        .contentShape(Rectangle())
        .onTapGesture {
            if !showToggle {
                action?()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MoreView()
            .environmentObject(PremiumSheetPresenter())
            .environmentObject(PurchaseManager())
    }
    .preferredColorScheme(.dark)
}
