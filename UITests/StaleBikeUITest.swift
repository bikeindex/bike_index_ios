//
//  StaleBikeUITest.swift
//  UITests
//
//  Created by Jack on 9/6/26.
//

import XCTest

final class StaleBikeUITest: XCTestCase {
    let app = XCUIApplication()
    var bikes_belonging_to_first_user: [String] = []
    var bikes_belonging_to_second_user: [String] = []

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    func test_staleBikesAreRemoved() throws {
        try MainContentRobot(app)
            .startWithSignIn()

            // Validate By-Status display
            .tapGroupingMenuButton()
            .tapGroupButton(for: Status.groupMode)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .identifyBikes(&bikes_belonging_to_first_user)
            .logOut()
//            .startWithSignIn(email: "", password: "")
//            .checkFirstBike(exists: true)
//            .identifyBikes(&bikes_belonging_to_second_user)

        XCTAssertFalse(bikes_belonging_to_first_user.isEmpty)
        XCTAssertNotEqual(bikes_belonging_to_first_user, bikes_belonging_to_second_user)

        let setOfFirstBikes = Set(bikes_belonging_to_first_user)
        let setOfSecondBikes = Set(bikes_belonging_to_second_user)
        XCTAssertTrue(setOfFirstBikes.isDisjoint(with: setOfSecondBikes))
    }

}

extension MainContentRobot {
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
