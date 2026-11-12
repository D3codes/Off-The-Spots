//
//  AppDelegate.swift
//  Off The Spots
//
//  Created by David Freeman on 10/25/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private var transactionUpdates: Task<Void, Never>?

    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        transactionUpdates = Task { await StoreHelper.observeTransactions() }
        return true
    }

    deinit {
        transactionUpdates?.cancel()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
