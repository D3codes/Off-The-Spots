import StoreKit
import StoreKitTest
import Testing
@testable import Off_The_Spots

@Suite(.serialized)
struct StoreHelperTests {
    @Test func restoreDiagnosticsIncludeTheStepAndUnderlyingCodes() {
        let syncDetails = StoreHelper.restoreDiagnosticDetails(
            step: .sync,
            error: StoreKitError.networkError(URLError(.notConnectedToInternet))
        )
        #expect(syncDetails.contains("Failed step: AppStore.sync()"))
        #expect(syncDetails.contains("Underlying error: NSURLErrorDomain (-1009)"))

        let cause = NSError(
            domain: "TestStoreService",
            code: 14,
            userInfo: [NSLocalizedDescriptionKey: "Private error description"]
        )
        let wrapper = NSError(domain: "TestStoreWrapper", code: 1, userInfo: [NSUnderlyingErrorKey: cause])
        let statusDetails = StoreHelper.restoreDiagnosticDetails(
            step: .subscriptionStatus,
            error: StoreKitError.systemError(wrapper)
        )
        #expect(statusDetails.contains("Failed step: Product.SubscriptionInfo.status(for:)"))
        #expect(statusDetails.contains("Underlying error: TestStoreWrapper (1)"))
        #expect(statusDetails.contains("Underlying error: TestStoreService (14)"))
        #expect(!statusDetails.contains("Private error description"))
    }

    @MainActor
    @Test(arguments: [false, true])
    func billingRetryGrantsProOnlyDuringGracePeriod(gracePeriodEnabled: Bool) async throws {
        let session = try SKTestSession(configurationFileNamed: "Off The Spots")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        session.shouldEnterBillingRetryOnRenewal = true
        session.billingGracePeriodIsEnabled = gracePeriodEnabled
        session.timeRate = .oneRenewalEveryTwoSeconds
        defer {
            session.clearTransactions()
            session.resetToDefaultState()
            StoreHelper.defaults.removeObject(forKey: UserDefaultsKeys.proExpirationDate)
        }

        _ = try await session.buyProduct(identifier: StoreHelper.monthlyPro)
        #expect(try await StoreHelper.refreshProEntitlement())
        #expect(StoreHelper.hasCachedActiveSubscription())

        let expectedState: Product.SubscriptionInfo.RenewalState = gracePeriodEnabled ? .inGracePeriod : .inBillingRetryPeriod
        let deadline = ContinuousClock.now + .seconds(8)
        var statuses = try await Product.SubscriptionInfo.status(for: StoreHelper.proGroupID)
        while !statuses.contains(where: { $0.state == expectedState }) && ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(100))
            statuses = try await Product.SubscriptionInfo.status(for: StoreHelper.proGroupID)
        }

        try #require(statuses.contains { $0.state == expectedState })
        #expect(StoreHelper.checkForActiveSubscription(in: statuses) == gracePeriodEnabled)
        #expect(StoreHelper.hasCachedActiveSubscription() == gracePeriodEnabled)
        if !gracePeriodEnabled {
            #expect(StoreHelper.defaults.object(forKey: UserDefaultsKeys.proExpirationDate) == nil)
        }
    }
}
