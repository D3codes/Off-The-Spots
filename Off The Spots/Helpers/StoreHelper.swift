//
//  StoreHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/9/25.
//

import StoreKit
import _StoreKit_SwiftUI

class StoreHelper {
    @MainActor static let defaults = UserDefaults.standard
    static let monthlyPro: String = "OTS_PRO_SUBSCRIPTION_MONTH"
    static let yearlyPro: String = "OTS_PRO_SUBSCRIPTION_YEAR"
    
    @MainActor static func checkForActiveSubscription(in taskState: EntitlementTaskState<[Product.SubscriptionInfo.Status]>) -> Bool {
        if let statuses = taskState.value {
            return checkForActiveSubscription(in: statuses)
        } else {
            return defaults.value(forKey: UserDefaultsKeys.proExpirationDate) as? Date ?? Date.distantPast > Date()
        }
    }
    
    private static func checkForActiveSubscription(in statuses: [Product.SubscriptionInfo.Status]) -> Bool {
        let activeStatuses = statuses.filter {
            $0.state != .revoked && $0.state != .expired
            && ($0.transaction.unsafePayloadValue.productID == monthlyPro || $0.transaction.unsafePayloadValue.productID == yearlyPro)
        }
        
        let isPro: Bool = !activeStatuses.isEmpty
        
        if isPro {
            let verification = activeStatuses.first!.transaction
            if let transaction = try? verification.payloadValue {
                let expirationDate: Date = transaction.expirationDate ?? Date.distantFuture
                let revocationDate: Date = transaction.revocationDate ?? Date.distantFuture
                
                print("Expiration: \(expirationDate), Revocation: \(revocationDate), Now: \(Date())")
                
                let proExpirationDate: Date = min(expirationDate, revocationDate)
                
                print("Pro Expiration: \(proExpirationDate)")
                DispatchQueue.main.async {
                    defaults.set(proExpirationDate, forKey: UserDefaultsKeys.proExpirationDate)
                }
            }
        }
        
        return isPro
    }
}
