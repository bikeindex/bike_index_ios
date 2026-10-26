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
    /// The label ("<year> <manufacturer>") of the bike transferred in
    /// ``test_transferredBikesAreRemoved``.
    var transferredBikeLabel: String?
    /// Provider's by-status bike list before the transfer, used to pick a
    /// transfer target and to assert the post-transfer state.
    var providerBikeLabels: [String] = []

    /// Dedicated sandbox accounts (bikeindex/bike_index#4656): the provider is
    /// seeded with exactly one bike to transfer, the recipient starts empty.
    static let transferProvider = "transfer_provider@bikeindex.org"
    static let transferRecipient = "transfer_recipient@bikeindex.org"
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
        // Self-heal: if a previous run left the bike with the recipient, transfer
        // it back to the provider so this run starts from the seeded state
        // (provider owns the bike, recipient owns nothing).
        try Self.healTransferState(app: app)

        // Provider signs in and groups by status.
        let provider = MainContentRobot(app)
        try provider
            .startWithSignIn(email: Self.transferProvider, password: Self.testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)

        // Wait for the grid to render before collecting labels.
        let bikePredicate = NSPredicate(format: "identifier BEGINSWITH 'Bike '")
        let firstBike = app.buttons.matching(bikePredicate).firstMatch
        XCTAssertTrue(
            firstBike.waitForExistence(timeout: Robot.defaultTimeout),
            "expected at least one bike to render in the by-status grid"
        )

        // Snapshot every bike the provider owns, grouped by status.
        providerBikeLabels = provider.identifyBikeLabels()
        XCTAssertFalse(providerBikeLabels.isEmpty, "provider should own at least one bike")
        guard !providerBikeLabels.isEmpty else { return }

        // The first bike in the by-status grid is the first "with owner" bike.
        let firstBikeLabel = providerBikeLabels.first!
        transferredBikeLabel = firstBikeLabel

        // Open that specific bike and transfer it to the recipient.
        try provider
            .tapBike(withLabel: firstBikeLabel)
            .tapEditButton()
            .finishWebViewLoading()

        try EditBikeRobot(app)
            .scrollToFooter()
            .tapTransferHideOrDelete()
            .typeNewOwner(email: Self.transferRecipient)
            .updateOwnership()
            .finishWebViewLoading()
            .back()
            .logOut()  // will go to Settings for us

        // Sign in as the recipient and accept the transfer. The web app
        // surfaces a "Your bike" claim card on the transferred bike's detail
        // page (an auto-opening modal, see app/views/bikes/_bike_show_overlays.html.haml
        // in bikeindex/bike_index) with a green CLAIM BIKE button. Tap it to
        // claim the bike, then sign back out so the provider sign-in below
        // starts from a clean signed-out state.
        try MainContentRobot(app)
            .signIn(email: Self.transferRecipient, password: Self.testPassword)
            .tapFirstBike()
            .claimBike()
            .back()
            .logOut()

        app.terminate()
        sleep(3)
        app.launch()
        let reSignedInProvider = MainContentRobot(app)
        try reSignedInProvider
            .startWithSignIn(email: Self.transferProvider, password: Self.testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)

        // The specific bike that was transferred must be gone from the
        // provider's list, and the remaining bikes must still be there.
        if let transferredBikeLabel {
            reSignedInProvider.checkNoBike(withLabel: transferredBikeLabel)
            for label in providerBikeLabels where label != transferredBikeLabel {
                reSignedInProvider.checkBike(withLabel: label, exists: true)
            }
        } else {
            XCTFail("Could not capture the transferred bike's label")
        }
    }

}

extension BikeDetailRobot {
    /// Claim a transferred bike. The web app surfaces a "Your bike" claim card
    /// on the bike detail page with a green CLAIM BIKE button. The button is a
    /// styled link (`<a class="btn btn-success">`), rendered in all caps by CSS
    /// (`text-transform: uppercase`), so query it as a `link` with the all-caps
    /// label. Fails if the card is not present - the recipient must see it for
    /// a pending transfer.
    @discardableResult
    func claimBike() -> Self {
        let webView = app.webViews.firstMatch
        XCTAssertTrue(
            webView.waitForExistence(timeout: Robot.defaultTimeout),
            "expected the bike detail web view to load for the claim"
        )

        let claimButton = webView.links["CLAIM BIKE"].firstMatch
        XCTAssertTrue(
            claimButton.waitForExistence(timeout: 20),
            "expected the CLAIM BIKE button on the recipient's bike detail page"
        )

        claimButton.tap()
        finishWebViewLoading()
        return self
    }

    /// Tolerant variant used only by the self-heal path: claim the bike if the
    /// claim card is present, otherwise no-op. Transfers between existing
    /// accounts may link ownership immediately server-side (no claim card), so
    /// the heal must not fail on its absence - the subsequent ``hasVisibleBike``
    /// check is the real assertion.
    @discardableResult
    func claimBikeIfNeeded() -> Self {
        let webView = app.webViews.firstMatch
        guard webView.waitForExistence(timeout: Robot.defaultTimeout) else {
            return self
        }
        let claimButton = webView.links["CLAIM BIKE"].firstMatch
        guard claimButton.waitForExistence(timeout: 10) else {
            return self  // no claim card - ownership was linked directly
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

    /// Whether at least one bike is currently visible in the app's by-status grid.
    func hasVisibleBike() -> Bool {
        let predicate = NSPredicate(format: "identifier BEGINSWITH 'Bike '")
        return app.buttons.matching(predicate).firstMatch.waitForExistence(timeout: 10)
    }
}

extension StaleBikeUITest {
    /// Ensure the seeded transfer state: the provider owns a bike, the recipient
    /// owns none. If a prior run transferred the bike to the recipient (and
    /// claimed it), sign in as the recipient and transfer the bike back to the
    /// provider. Idempotent - a no-op when the state is already correct.
    static func healTransferState(app: XCUIApplication) throws {
        // 1. Check whether the provider still owns a bike.
        try MainContentRobot(app)
            .startWithSignIn(email: transferProvider, password: testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)

        let providerRobot = MainContentRobot(app)
        if providerRobot.hasVisibleBike() {
            // State is already correct - provider owns the bike. Sign out and return.
            try providerRobot.logOut()
            return
        }

        // 2. Provider has no bike - it must be with the recipient. Sign out of
        //    the provider, sign in as the recipient, and transfer the bike back.
        try providerRobot.logOut()

        let recipient = MainContentRobot(app)
        try recipient
            .signIn(email: transferRecipient, password: testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)

        // Wait for the recipient's grid to render.
        let bikePredicate = NSPredicate(format: "identifier BEGINSWITH 'Bike '")
        let firstBike = app.buttons.matching(bikePredicate).firstMatch
        XCTAssertTrue(
            firstBike.waitForExistence(timeout: Robot.defaultTimeout),
            "self-heal: expected the recipient to own a bike to transfer back"
        )

        // Snapshot the recipient's bikes and pick the first one to transfer back.
        let recipientLabels = recipient.identifyBikeLabels()
        XCTAssertFalse(recipientLabels.isEmpty, "self-heal: recipient has no bikes to transfer back")
        guard let firstLabel = recipientLabels.first else { return }

        // Open the bike and transfer ownership back to the provider.
        try recipient
            .tapBike(withLabel: firstLabel)
            .tapEditButton()
            .finishWebViewLoading()

        try EditBikeRobot(app)
            .scrollToFooter()
            .tapTransferHideOrDelete()
            .typeNewOwner(email: transferProvider)
            .updateOwnership()
            .finishWebViewLoading()
            .back()
            .logOut()

        // 3. Sign in as the provider. If a claim card is present (pending
        //    transfer), claim it; otherwise the ownership was linked directly
        //    server-side. Either way the bike must now appear in the provider's
        //    list (matching the seeded state).
        let healedProvider = MainContentRobot(app)
        try healedProvider
            .startWithSignIn(email: transferProvider, password: testPassword)
            .tapGroupingMenuButton()
            .tapGroupButton(mode: .byStatus)

        // Open the bike (if any) and claim it if a claim card is shown, then go
        // back to the list. ``claimBikeIfNeeded`` is tolerant: it no-ops when
        // there is no claim card (ownership linked directly server-side).
        _ = healedProvider.tapFirstBike().claimBikeIfNeeded().back()

        XCTAssertTrue(
            healedProvider.hasVisibleBike(),
            "self-heal: expected the provider to own the bike after transferring it back"
        )
        try healedProvider.logOut()
    }
}
