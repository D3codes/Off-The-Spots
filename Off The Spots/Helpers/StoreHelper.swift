//
//  StoreHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/9/25.
//

import StoreKit
import _StoreKit_SwiftUI
import OSLog

class StoreHelper {
    private static let logger = Logger(subsystem: "codes.d3.Off-The-Spots", category: "StoreKit")
    @MainActor static let defaults = UserDefaults.standard
    static let monthlyPro: String = "OTS_PRO_SUBSCRIPTION_MONTH"
    static let yearlyPro: String = "OTS_PRO_SUBSCRIPTION_YEAR"
    static let proGroupID: String = "21825638"
    
    @MainActor static func checkForActiveSubscription(in taskState: EntitlementTaskState<[Product.SubscriptionInfo.Status]>) -> Bool {
        if let statuses = taskState.value {
            return checkForActiveSubscription(in: statuses)
        } else {
            return hasCachedActiveSubscription()
        }
    }

    @MainActor static func hasCachedActiveSubscription() -> Bool {
        defaults.value(forKey: UserDefaultsKeys.proExpirationDate) as? Date ?? Date.distantPast > Date()
    }

    @MainActor static func hasActiveSubscription(groupID: String = proGroupID) async -> Bool {
        do {
            return try await refreshProEntitlement(groupID: groupID)
        } catch {
            return hasCachedActiveSubscription()
        }
    }
    
    @MainActor static func refreshProEntitlement(groupID: String = proGroupID) async throws -> Bool {
        let statuses = try await Product.SubscriptionInfo.status(for: groupID)
        return checkForActiveSubscription(in: statuses)
    }

    @MainActor static func observeTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result,
                  isProProduct(transaction.productID) else { continue }

            do {
                _ = try await refreshProEntitlement()
                await transaction.finish()
            } catch {
                logger.error("Could not refresh Pro access for a StoreKit transaction: \(error.localizedDescription, privacy: .private)")
            }
        }
    }

    @MainActor static func checkForActiveSubscription(in statuses: [Product.SubscriptionInfo.Status]) -> Bool {
        var isPro = false
        var cachedExpiration: Date?

        for status in statuses {
            guard status.state == .subscribed || status.state == .inGracePeriod,
                  case .verified(let transaction) = status.transaction,
                  isProProduct(transaction.productID) else { continue }

            isPro = true
            let expiration: Date?
            if status.state == .inGracePeriod {
                expiration = (try? status.renewalInfo.payloadValue)?.gracePeriodExpirationDate
            } else {
                expiration = transaction.expirationDate
            }
            if let expiration, expiration > (cachedExpiration ?? .distantPast) {
                cachedExpiration = expiration
            }
        }

        defaults.set(cachedExpiration, forKey: UserDefaultsKeys.proExpirationDate)
        return isPro
    }

    private static func isProProduct(_ productID: String) -> Bool {
        productID == monthlyPro || productID == yearlyPro
    }
}
