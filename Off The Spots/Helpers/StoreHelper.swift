//
//  StoreHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/9/25.
//

import StoreKit

class StoreHelper {
    @MainActor static let defaults = UserDefaults.standard
    static let monthlyPro: String = "OTS_PRO_SUBSCRIPTION_MONTH"
    static let yearlyPro: String = "OTS_PRO_SUBSCRIPTION_YEAR"
    
    static func checkForActiveSubscription(in statuses: [Product.SubscriptionInfo.Status]) -> Bool {
        var isPro: Bool = false
        
        statuses.forEach { status in
            let productId: String = status.transaction.unsafePayloadValue.productID
            let isProProductId: Bool = productId == monthlyPro || productId == yearlyPro
            let isActiveStatus: Bool = status.state != .revoked && status.state != .expired
            
            let verification = status.transaction
            switch verification {
            case .verified:
                if isProProductId && isActiveStatus {
                    if let transaction = try? verification.payloadValue {
                        let expirationDate: Date? = transaction.expirationDate
                        let revocationDate: Date? = transaction.revocationDate
                        
                        let proExpirationDate: Date = min(expirationDate ?? Date.distantFuture, revocationDate ?? Date.distantFuture)
                        DispatchQueue.main.async {
                            defaults.set(proExpirationDate, forKey: UserDefaultsKeys.proExpirationDate)
                        }
                    }
                    
                    isPro = true
                }
            case .unverified(let t, let error):
                print("Transaction ID \(t.id) for \(t.productID) is unverified: \(error)")
            }
        }
        
        return isPro
    }
}
