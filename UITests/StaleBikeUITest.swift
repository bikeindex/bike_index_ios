//
//  StaleBikeUITest.swift
//  UITests
//
//  Created by Jack on 9/6/26.
//

import XCTest

/// This should test two scenarios
/// 1. User1 signs in, sees User1's bikes, logs out.
///     User2 signs in, sees User2's bikes only.
///     Failure condition: User2 sees User1's bikes.
/// 2. User1 signs in, transfers ownership of a bike, logs out, signs in, the
///     transferred bike is no longer in their list of bikes.
///     Failure condition: User1 sees the transfered-ownership bike.
final class StaleBikeUITest: XCTestCase {
    let app = XCUIApplication()
    var bikes_belonging_to_first_user: [String] = []
    var bikes_belonging_to_second_user: [String] = []

    /// Accounts used for the transfer test.
    ///
    /// TODO: Switch back to dedicated sandbox accounts (`transfer_provider@` /
    /// `transfer_recipient@bikeindex.org`) once they have bikes seeded. Until
    /// then, reuse `user@` (provider) and `api@` (recipient) so the test can
    /// run against existing bikes.
    static let transferProvider = "user@bikeindex.org"
    static let transferRecipient = "api@bikeindex.org"
    static let testPassword = "pleaseplease12"

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Three sign-in flows + webview transfer + claim: well beyond the
        // 120 s scheme default.
        executionTimeAllowance = 600
        XCUIDevice.shared.orientation = .portrait
    }

    // TODO: Validate this test
    func test_staleBikesAreRemoved() throws {
        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: Self.testPassword)

            // Validate By-Status display
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .identifyBikes(&bikes_belonging_to_first_user)
            .logOut()

            .signIn(email: "member@brakebills.edu", password: Self.testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)
            .checkBike(section: Status.unregisteredParkingNotification, index: 1, exists: true)
            .identifyBikes(&bikes_belonging_to_second_user)

        XCTAssertFalse(bikes_belonging_to_first_user.isEmpty)
        XCTAssertFalse(bikes_belonging_to_second_user.isEmpty)
        XCTAssertNotEqual(bikes_belonging_to_first_user, bikes_belonging_to_second_user)

        /*
         TODO: Alright so this UI test isn't behaving quite right. Let's move on to validating in the app and in the unit tests. Then we can come back to the UITest.
         */
        let setOfFirstBikes = Set(bikes_belonging_to_first_user)
        let setOfSecondBikes = Set(bikes_belonging_to_second_user)
        XCTAssertTrue(
            setOfFirstBikes.isDisjoint(with: setOfSecondBikes),
            "expected distinct sets, found A) <\(setOfFirstBikes)> -- vs -- <\(setOfSecondBikes)>")
    }

    /// Provider transfers a bike to a dedicated recipient account. After the
    /// recipient accepts, the bike must no longer appear in the provider's
    /// by-status "with owner" list on the provider's next sign-in (the stale-bike
    /// cleanup path).
    func test_transferredBikesAreRemoved() throws {
        try MainContentRobot(app)
            .startWithSignIn(email: Self.transferProvider, password: Self.testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .tapFirstBike()
            .tapEditButton()
            .finishWebViewLoading()
            .scrollToFooter()
            .tapTransferHideOrDelete()
            .typeNewOwner(email: Self.transferRecipient)
            .updateOwnership()
            .finishWebViewLoading()
            .back()
            .logOut()  // will go to Settings for us

        // Sign in as the recipient and accept the transfer. The web app
        // surfaces a "Your bike" card with a CLAIM BIKE button on the bike
        // detail page; claim it, then sign back out so the provider sign-in
        // below starts from a clean signed-out state.
        try MainContentRobot(app)
            .signIn(email: Self.transferRecipient, password: Self.testPassword)
            .tapFirstBike()
            .claimBikeIfNeeded()
            .back()
            .logOut()

        app.terminate()
        sleep(3)
        app.launch()
        try MainContentRobot(app)
            .startWithSignIn(email: Self.transferProvider, password: Self.testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)
            .checkBike(section: Status.withOwner, index: 1, exists: false)
    }

}

extension BikeDetailRobot {
    /// If the signed-in user is the pending recipient of a bike transfer, claim
    /// it. The web app renders a "Your bike" card with a CLAIM BIKE button on the
    /// bike detail page. Best-effort: if the card is not rendered, it's a no-op.
    @discardableResult
    func claimBikeIfNeeded() -> Self {
        let webView = app.webViews.firstMatch
        guard webView.waitForExistence(timeout: Robot.defaultTimeout) else {
            return self
        }

        let claimButton = webView.buttons["CLAIM BIKE"].firstMatch
        guard claimButton.waitForExistence(timeout: 10) else {
            print("[\(self)] no pending transfer offer found to claim; continuing")
            return self
        }

        claimButton.tap()
        finishWebViewLoading()
        return self
    }
}

extension MainContentRobot {
    @discardableResult
    func identifyBikes(_ identifiedBikes: inout [String]) -> Self {
        let predicate = NSPredicate(format: "identifier BEGINSWITH 'Bike'")
        let bikeButtons = app.buttons.matching(predicate)
        let filteredBikes = bikeButtons.allElementsBoundByIndex.map {
            $0.identifier
            // TODO: do some validation to make sure these are the right elements and we're not getting non-bike UI elements
            // TODO: Transform to appropriate bike identifiers for comparison against other account
        }
        identifiedBikes.append(contentsOf: filteredBikes)

        return self
    }
}
