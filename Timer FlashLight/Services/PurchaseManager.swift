//
//  PurchaseManager.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import StoreKit

/// Manages in-app purchase and restore for premium (StoreKit 2).
@MainActor
final class PurchaseManager: ObservableObject {
    // MARK: - Published

    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var product: Product?

    /// True when the user has unlocked premium (current transaction or restored).
    @Published private(set) var isPremiumUnlocked: Bool {
        didSet {
            UserDefaults.standard.set(isPremiumUnlocked, forKey: AppConstants.UserDefaultsKeys.isPremiumUnlocked)
        }
    }

    // MARK: - Private

    private let productID = AppConstants.IAP.premiumLifetimeProductID

    // MARK: - Init

    init() {
        self.isPremiumUnlocked = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isPremiumUnlocked)
        Task {
            await loadProduct()
            await updatePremiumFromTransactions()
        }
    }

    // MARK: - Load Product

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            errorMessage = "Could not load product."
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product = product else {
            errorMessage = "Product not available."
            return
        }
        guard !isPurchasing else { return }
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePremiumFromTransactions()
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Restore

    func restore() async {
        guard !isRestoring else { return }
        isRestoring = true
        errorMessage = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await updatePremiumFromTransactions()
            if !isPremiumUnlocked {
                errorMessage = "No previous purchase to restore."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Helpers

    private func updatePremiumFromTransactions() async {
        var hasPurchase = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == productID {
                hasPurchase = true
                break
            }
        }
        if !hasPurchase {
            for await result in Transaction.all {
                guard case .verified(let transaction) = result else { continue }
                if transaction.productID == productID {
                    hasPurchase = true
                    break
                }
            }
        }
        if hasPurchase {
            isPremiumUnlocked = true
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}
