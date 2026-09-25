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

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    // user@bikeindex.org owns a small, stable set of named fixture bikes (see
    // db/seeds/seed_test_users.rb in the Rails repo). We match on their rendered labels
    // ("<year> <manufacturer>") so the test is independent of list position and order.
    private let userFixtureBikeLabels = ["2019 Specialized", "2022 Trek", "2020 Cannondale"]
    private let transferSourceBikeLabel = "2020 Cannondale"

    func test_staleBikesAreRemoved() throws {
        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")

            // Validate By-Status display: the primary user's fixture bikes are present.
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(withLabel: userFixtureBikeLabels[0], exists: true)
            .checkBike(withLabel: userFixtureBikeLabels[1], exists: true)
            .checkBike(withLabel: userFixtureBikeLabels[2], exists: true)
            .logOut()

        bikes_belonging_to_first_user = MainContentRobot(app).identifyBikeLabels()

        try MainContentRobot(app)
            .signIn(email: "member@brakebills.edu", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            // member has an unregistered (parking-notification) bike; assert by position
            // only for existence (its label is not a stable fixture).
            .checkBike(section: Status.unregisteredParkingNotification, index: 1, exists: true)
            .logOut()

        bikes_belonging_to_second_user = MainContentRobot(app).identifyBikeLabels()

        XCTAssertFalse(bikes_belonging_to_first_user.isEmpty)
        XCTAssertFalse(bikes_belonging_to_second_user.isEmpty)
        XCTAssertNotEqual(bikes_belonging_to_first_user, bikes_belonging_to_second_user)

        let setOfFirstBikes = Set(bikes_belonging_to_first_user)
        let setOfSecondBikes = Set(bikes_belonging_to_second_user)
        XCTAssertTrue(
            setOfFirstBikes.isDisjoint(with: setOfSecondBikes),
            "expected distinct sets, found A) <\(setOfFirstBikes)> -- vs -- <\(setOfSecondBikes)>")
    }

    /// Transfers one of user@bikeindex.org's fixture bikes to api@bikeindex.org and
    /// verifies the recipient can claim it and the source user no longer sees it.
    ///
    /// NOTE: This mutates shared-sandbox state, so the sandbox needs a reseed between runs.
    /// It transfers `2020 Cannondale` specifically so the other two fixture bikes
    /// (`2019 Specialized`, `2022 Trek`) stay intact for the other UI tests.
    func test_transferredBikesAreRemoved() throws {
        let sourceBikeLabel = transferSourceBikeLabel

        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(withLabel: sourceBikeLabel, exists: true)
            .tapBike(withLabel: sourceBikeLabel)
            .tapEditButton()
            .finishWebViewLoading()
            .scrollToFooter()
            .tapTransferHideOrDelete()
            .typeNewOwner(email: "api@bikeindex.org")
            .updateOwnership()
            .finishWebViewLoading()
            .back()
            .logOut()  // will go to Settings for us

        app.terminate()
        sleep(3)
        app.launch()
        try MainContentRobot(app)
            .startWithSignIn(email: "api@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(withLabel: sourceBikeLabel, exists: true)
            .tapBikeForEdit(withLabel: sourceBikeLabel)
            .claimBike()
            .back()
            .logOut()

        app.terminate()
        sleep(3)
        app.launch()
        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkNoBike(withLabel: sourceBikeLabel)
            // The other fixture bikes should be untouched.
            .checkBike(withLabel: userFixtureBikeLabels[0], exists: true)
            .checkBike(withLabel: userFixtureBikeLabels[1], exists: true)
    }

}


