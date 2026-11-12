import StoreKit
import StoreKitTest
import XCTest

final class SubscriptionFlowUITests: XCTestCase {
    @MainActor
    func testFailedPurchaseCanBeRetriedAndThankYouRequiresPro() async throws {
        let session = try startStoreKitSession()
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Songs"].buttons.firstMatch.tap()
        checkRestore(in: app, message: "No active Off The Spots Pro subscription was found for this App Store account.")

        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Subscribe to Pro")).firstMatch.tap()
        let subscribe = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Subscribe")).firstMatch
        XCTAssertTrue(subscribe.waitForExistence(timeout: 10), app.debugDescription)

        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .purchase)
        subscribe.tap()
        let purchaseAlert = app.alerts.firstMatch
        XCTAssertTrue(purchaseAlert.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertFalse(app.staticTexts["Thank You!"].exists)
        XCTAssertFalse(purchaseAlert.buttons["Copy Diagnostic Details"].exists)
        purchaseAlert.buttons.firstMatch.tap()

        try await session.setSimulatedError(nil, forAPI: .purchase)
        subscribe.tap()
        XCTAssertTrue(app.staticTexts["Thank You!"].waitForExistence(timeout: 10), app.debugDescription)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10), app.debugDescription)

        checkRestore(in: app, message: "Your Off The Spots Pro subscription is active.")
    }

    @MainActor
    func testRestoreFailureCanCopyDiagnosticDetails() async throws {
        let session = try startStoreKitSession()
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Songs"].buttons.firstMatch.tap()

        let failureMessage = "Unable to check your subscription with the App Store. Please try again later."
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .appStoreSync)
        checkRestore(in: app, message: failureMessage, canCopyDetails: true)

        try await session.setSimulatedError(.generic(.userCancelled), forAPI: .appStoreSync)
        checkRestore(in: app, message: "Restore was cancelled.")
    }

    @MainActor
    func testPendingPurchaseUnlocksSetListsWhenApproved() async throws {
        let session = try startStoreKitSession()
        session.askToBuyEnabled = true
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Set Lists"].tap()
        app.buttons["Add Set List"].tap()

        let subscribe = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Subscribe")).firstMatch
        XCTAssertTrue(subscribe.waitForExistence(timeout: 10), app.debugDescription)
        subscribe.tap()

        let pendingPurchase = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            session.allTransactions().contains(where: \.pendingAskToBuyConfirmation)
        }, object: nil)
        await fulfillment(of: [pendingPurchase], timeout: 10)
        XCTAssertFalse(app.staticTexts["Thank You!"].exists)

        let transaction = try XCTUnwrap(session.allTransactions().first(where: \.pendingAskToBuyConfirmation))
        try session.approveAskToBuyTransaction(identifier: transaction.identifier)
        let thanks = app.staticTexts["Thank You!"]
        XCTAssertTrue(thanks.waitForExistence(timeout: 10), app.debugDescription)
        app.navigationBars.buttons["Cancel"].tap()
        XCTAssertTrue(thanks.waitForNonExistence(timeout: 10), app.debugDescription)
        app.buttons["Add Set List"].tap()
        XCTAssertTrue(app.navigationBars["Add Set List"].waitForExistence(timeout: 10), app.debugDescription)
    }

    private func startStoreKitSession() throws -> SKTestSession {
        continueAfterFailure = false
        let configuration = try XCTUnwrap(Bundle(for: SubscriptionFlowUITests.self).url(forResource: "Off The Spots", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: configuration)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        addTeardownBlock {
            session.clearTransactions()
            session.resetToDefaultState()
        }
        return session
    }

    @MainActor
    private func checkRestore(in app: XCUIApplication, message: String, canCopyDetails: Bool = false) {
        app.buttons["Restore Subscription"].tap()
        let alert = app.alerts["Restore Subscription"]
        XCTAssertTrue(alert.staticTexts[message].waitForExistence(timeout: 10), app.debugDescription)
        let copy = alert.buttons["Copy Diagnostic Details"]
        XCTAssertEqual(copy.exists, canCopyDetails)
        if canCopyDetails {
            copy.tap()
        } else {
            alert.buttons["OK"].tap()
        }
    }
}
