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

    // TODO: Validate this test
    func test_staleBikesAreRemoved() throws {
        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")

            // Validate By-Status display
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .identifyBikes(&bikes_belonging_to_first_user)
            .logOut()

            .signIn(email: "member@brakebills.edu", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
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

    func test_transferredBikesAreRemoved() throws {
        try MainContentRobot(app)
        // TODO: Change this to a different account so I don't statefully break other tests!
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .tapFirstBike()
            .tapEditButton()
            .finishWebViewLoading()
            .scrollToFooter()
            .tapTransferHideOrDelete()
            .typeNewOwner(email: "api@bikeindex.org")
            .updateOwnership()
            .finishWebViewLoading()
            .back()
            .logOut()  // will go to Settings for us

        // TODO: Need to sign-in with the recipient account and accept the transfer

        app.terminate()
        sleep(3)
        app.launch()
        try MainContentRobot(app)
            .startWithSignIn(email: "user@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(section: Status.withOwner, index: 1, exists: false)
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
