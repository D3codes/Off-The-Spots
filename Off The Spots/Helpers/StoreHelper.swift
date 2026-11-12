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

    enum RestoreStep: String {
        case sync = "AppStore.sync()"
        case subscriptionStatus = "Product.SubscriptionInfo.status(for:)"
    }
    
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

    static func restoreDiagnosticDetails(step: RestoreStep, error: any Error) -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        let reportedError = error as NSError
        var details = [
            "Off The Spots \(version) (\(build))",
            "iOS \(ProcessInfo.processInfo.operatingSystemVersionString)",
            "Time (UTC): \(Date().ISO8601Format())",
            "Failed step: \(step.rawValue)",
            "Error: \(reportedError.domain) (\(reportedError.code))"
        ]

        var underlyingError: NSError?
        switch error {
        case StoreKitError.networkError(let cause):
            details.append("StoreKit error: networkError")
            underlyingError = cause as NSError
        case StoreKitError.systemError(let cause):
            details.append("StoreKit error: systemError")
            underlyingError = cause as NSError
        default:
            underlyingError = reportedError.userInfo[NSUnderlyingErrorKey] as? NSError
        }

        // Bound the chain in case an underlying error refers back to its wrapper.
        for _ in 0..<4 {
            guard let cause = underlyingError else { break }
            details.append("Underlying error: \(cause.domain) (\(cause.code))")
            underlyingError = cause.userInfo[NSUnderlyingErrorKey] as? NSError
        }

        return details.joined(separator: "\n")
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
