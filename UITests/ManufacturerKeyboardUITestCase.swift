//
//  ManufacturerKeyboardUITestCase.swift
//  UITests
//
//  Created by Jack on 4/14/24.
//

import XCTest

@MainActor
final class ManufacturerKeyboardUITestCase: XCTestCase {
    let timeout: TimeInterval = 90
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_ManufacturerEntryView_keyboard_control() throws {
        app.launch()
        try signIn(app: app)

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
    }
}
