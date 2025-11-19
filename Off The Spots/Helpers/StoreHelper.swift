//
//  StoreHelper.swift
//  Off The Spots
//
//  Created by David Freeman on 11/9/25.
//

import StoreKit

class StoreHelper {
    let monthlyPro: String = "OTS_PRO_SUBSCRIPTION_MONTH"
    let yearlyPro: String = "OTS_PRO_SUBSCRIPTION_YEAR"
    
    func checkForActiveSubscription(in statuses: [Product.SubscriptionInfo.Status]) -> Bool {
        var isPro: Bool = false
        
        statuses.forEach { status in
            let productId: String = status.transaction.unsafePayloadValue.productID
            let isProProductId: Bool = productId == monthlyPro || productId == yearlyPro
            let isActiveStatus: Bool = status.state != .revoked && status.state != .expired
            
//            print("Product ID: \(productId), isProProductId: \(isProProductId), isActiveStatus: \(isActiveStatus)")
            
            switch status.transaction {
            case .verified:
                if isProProductId && isActiveStatus {
                    isPro = true
                }
            case .unverified(let t, let error):
                print("Transaction ID \(t.id) for \(t.productID) is unverified: \(error)")
            }
        }
        
        return isPro
    }
}
