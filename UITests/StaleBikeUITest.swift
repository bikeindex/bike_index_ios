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
//        XCTFail("Todo: implement scenario 2 after transferring a bike.")
        try MainContentRobot(app)
            .startWithSignIn(email: "api@bikeindex.org", password: "pleaseplease12")
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)
            .checkBike(section: Status.withOwner, index: 1, exists: true)
            .tapFirstBike()
            .tapEditButton()
            .tapEditDetails()
            .tapEditTransferHideOrDelete()

        let webViewsQuery = app.webViews
        let element3 = webViewsQuery/*@START_MENU_TOKEN@*/.containing(.link, identifier: "Skip to main content").firstMatch/*[[".element(boundBy: 2)",".containing(.other, identifier: \"content information\").firstMatch",".containing(.other, identifier: \"main\").firstMatch",".containing(.link, identifier: \"Skip to main content\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element3.swipeUp()
        app/*@START_MENU_TOKEN@*/.staticTexts["Edit this bike"]/*[[".links[\"Edit this bike\"].staticTexts",".links.staticTexts[\"Edit this bike\"]",".staticTexts[\"Edit this bike\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element4 = webViewsQuery/*@START_MENU_TOKEN@*/.containing(.other, identifier: "Details: Intense").firstMatch/*[[".element(boundBy: 2)",".containing(.other, identifier: \"main\").firstMatch",".containing(.link, identifier: \"Skip to main content\").firstMatch",".containing(.other, identifier: \"Details: Intense\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element4.swipeUp()
        element4.swipeUp()
        element4.swipeUp()
        app/*@START_MENU_TOKEN@*/.staticTexts["Transfer, Hide or Delete"]/*[[".links[\"Transfer, Hide or Delete\"].staticTexts",".links.staticTexts[\"Transfer, Hide or Delete\"]",".staticTexts[\"Transfer, Hide or Delete\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element5 = app/*@START_MENU_TOKEN@*/.textFields["Owner email"]/*[[".otherElements.textFields[\"Owner email\"]",".textFields",".textFields[\"Owner email\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element5.tap()
        element5.doubleTap()
        element5.typeText("2")
        app/*@START_MENU_TOKEN@*/.buttons["Update ownership"]/*[[".otherElements[\"form\"].buttons",".otherElements.buttons[\"Update ownership\"]",".buttons[\"Update ownership\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.otherElements["form"]/*[[".otherElements",".containing(.textField, identifier: \"Owner email\")",".containing(.other, identifier: \"Owner email\")",".containing(.other, identifier: \"TRANSFER OWNERSHIP\")",".otherElements[\"form\"]"],[[[-1,4],[-1,0,1]],[[-1,4],[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.swipeDown()
        app/*@START_MENU_TOKEN@*/.buttons["Close"]/*[[".otherElements[\"alert\"].buttons",".otherElements.buttons[\"Close\"]",".buttons[\"Close\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element6 = app/*@START_MENU_TOKEN@*/.buttons["Edit"]/*[[".navigationBars.buttons[\"Edit\"]",".buttons[\"Edit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element6.tap()
        element6.tap()
        element6.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["View Bike"]/*[[".links[\"View Bike\"].staticTexts",".links.staticTexts[\"View Bike\"]",".staticTexts[\"View Bike\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element3.swipeUp()
        element3.swipeDown()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons[\"Bike Index\"]",".buttons[\"BackButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["settingsMenu"]/*[[".navigationBars",".buttons[\"Settings\"]",".buttons[\"settingsMenu\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"]/*[[".navigationBars",".buttons",".buttons[\"Bike Index\"]",".buttons[\"BackButton\"]"],[[[-1,3],[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.windows.element(boundBy: 1).swipeUp()

        sleep(600)
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
