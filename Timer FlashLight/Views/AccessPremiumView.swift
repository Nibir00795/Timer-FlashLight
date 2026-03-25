//
//  AccessPremiumView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import StoreKit

/// Access Premium paywall screen matching Figma design (node 1-821).
struct AccessPremiumView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseManager: PurchaseManager

    private let features: [(title: String, description: String)] = [
        ("Ad-Free Experience", "Enjoy a clean, distraction-free interface with zero ads to access the flashlight and Screen light."),
        ("Custom Timer Control", "Set any custom timer to automate your flashlight exactly the way you need."),
        ("Colours in Screen Mode", "Easily swipe among 12 ready-made colour options to suit your mood or create ambience."),
        ("Auto-Flash on Startup", "Automatically activates the flashlight as soon as the app opens.")
    ]

    private let premiumIconSize: CGFloat = 40
    private let timelineLineWidth: CGFloat = 1.5

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        titleSection
                        featureList
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                pricingSection
            }
        }
        .alert("Purchase", isPresented: Binding(
            get: { purchaseManager.errorMessage != nil },
            set: { if !$0 { purchaseManager.clearError() } }
        )) {
            Button("OK", role: .cancel) {
                purchaseManager.clearError()
            }
        } message: {
            if let message = purchaseManager.errorMessage {
                Text(message)
            }
        }
        .onChange(of: purchaseManager.isPremiumUnlocked) { isPremium in
            if isPremium {
                isPresented = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image("ic_close")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(AppTheme.Colors.textLight)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Close")
            .padding(.leading, AppTheme.Spacing.xl)
            .padding(.top, AppTheme.Spacing.md)
            Spacer()
        }
        .frame(height: 48)
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Access Premium")
            .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(24)))
            .fontWeight(.regular)
            .foregroundColor(Color(hex: "E6E6E6"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.lg)
    }

    // MARK: - Feature List (with timeline)

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                premiumFeatureRow(
                    title: feature.title,
                    description: feature.description,
                    titleSize: AppTheme.Typography.scaledSize(index >= 2 ? 17 : 16),
                    descriptionSize: AppTheme.Typography.scaledSize(index == 0 ? 16 : 15)
                )
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
        .background(
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color(hex: "595959"))
                    .frame(width: timelineLineWidth, height: geometry.size.height)
                    .offset(x: premiumIconSize / 2 - timelineLineWidth / 2)
            }
        )
    }

    private func premiumFeatureRow(title: String, description: String, titleSize: CGFloat = 16, descriptionSize: CGFloat = 15) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            premiumIconCircle
                .frame(width: premiumIconSize, height: premiumIconSize)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(.custom(AppTheme.Typography.sairaFontName, size: titleSize))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "E6E6E6"))
                Text(description)
                    .font(.custom(AppTheme.Typography.sairaFontName, size: descriptionSize))
                    .fontWeight(.regular)
                    .foregroundColor(Color(hex: "BABABA"))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var premiumIconCircle: some View {
        Image("ic_paywall_checkmark")
            .resizable()
            .renderingMode(.original)
            .frame(width: premiumIconSize, height: premiumIconSize)
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 20) {
            pricingText
            proceedButton
            restoreButton
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F9FAFE"))
    }

    private var pricingText: some View {
        VStack(spacing: 4) {
            Text("50% Off")
                .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(16)))
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.textDark)
            if let product = purchaseManager.product {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if let wasPriceString = wasPriceString(for: product) {
                        Text(wasPriceString)
                            .strikethrough(true, color: Color(hex: "808080"))
                            .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(16)))
                            .fontWeight(.regular)
                            .foregroundColor(Color(hex: "808080"))
                    }
                    Text("\(product.displayPrice) / Lifetime")
                        .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(16)))
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textDark)
                }
            } else {
                Text("— / Lifetime")
                    .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(16)))
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.textDark)
            }
        }
    }

    /// Doubles the product price, rounds to a locale-appropriate value (.99 for USD/EUR, round 100/1000 for JPY/KRW etc.), and formats as localized currency.
    private func wasPriceString(for product: Product) -> String? {
        let priceDouble = (product.price as NSDecimalNumber).doubleValue
        let doubled = priceDouble * 2
        let currencyCode = Locale.current.currency?.identifier ?? "USD"
        let wasValue: Double
        switch currencyCode {
        case "JPY", "KRW":
            wasValue = (doubled / 100).rounded(.up) * 100
        case "VND", "IDR":
            wasValue = (doubled / 1000).rounded(.up) * 1000
        case "TWD", "INR":
            wasValue = (doubled / 10).rounded(.up) * 10
        default:
            wasValue = floor(doubled) + 0.99
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        let noDecimals: Set<String> = ["JPY", "KRW", "VND", "IDR", "TWD", "INR"]
        formatter.maximumFractionDigits = noDecimals.contains(currencyCode) ? 0 : 2
        formatter.minimumFractionDigits = formatter.maximumFractionDigits
        return formatter.string(from: NSNumber(value: wasValue))
    }

    private var proceedButton: some View {
        Button(action: proceedTapped) {
            Group {
                if purchaseManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.textDark))
                } else {
                    Text("Proceed")
                        .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(15)))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "222222"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
        }
        .disabled(purchaseManager.isPurchasing)
        .background(AppTheme.Colors.success)
        .cornerRadius(30)
    }

    private var restoreButton: some View {
        Button(action: restoreTapped) {
            Group {
                if purchaseManager.isRestoring {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "606060")))
                        .scaleEffect(0.9)
                } else {
                    Text("Restore Purchase")
                        .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(15)))
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "606060"))
                }
            }
        }
        .disabled(purchaseManager.isRestoring)
    }

    // MARK: - Actions

    private func proceedTapped() {
        Task {
            await purchaseManager.purchase()
        }
    }

    private func restoreTapped() {
        Task {
            await purchaseManager.restore()
        }
    }
}

// MARK: - Preview

#Preview {
    AccessPremiumView(isPresented: .constant(true), purchaseManager: PurchaseManager())
        .preferredColorScheme(.dark)
}
