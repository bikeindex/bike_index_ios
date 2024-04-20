//
//  ManufacturerKeyboardUITestCase.swift
//  BikeIndexUITests
//
//  Created by Jack on 4/14/24.
//

import XCTest

final class ManufacturerKeyboardUITestCase: XCTestCase {
    let timeout: TimeInterval = 10
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_ManufacturerEntryView_keyboard_control() throws {
        app.launch()

        signin()

        let registerABike = app.buttons["Register a bike"]
        _ = registerABike.waitForExistence(timeout: timeout)
        registerABike.tap()

        let manufacturerEntryView = app.textFields["manufacturerSearchTextField"]
        _ = manufacturerEntryView.waitForExistence(timeout: timeout)
        manufacturerEntryView.tap()

        manufacturerEntryView.typeText("J")

        manufacturerEntryView.typeText("a")
        manufacturerEntryView.typeText("m")
        manufacturerEntryView.typeText("is")
        manufacturerEntryView.typeText("")
    }

    // MARK: - Helpers

    func signin() {
        let signIn = app.buttons["SignIn"]
        let result = signIn.waitForExistence(timeout: 2)
        if result {
            signIn.tap()
        }
    }

}
