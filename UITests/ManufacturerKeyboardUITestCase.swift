//
//  ManufacturerKeyboardUITestCase.swift
//  UITests
//
//  Created by Jack on 4/14/24.
//

import XCTest

@MainActor
final class ManufacturerKeyboardUITestCase: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_ManufacturerEntryView_keyboard_control() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapRegisterBikeButton()
            .tapManufacturerTextField()
            .typeIntoManufacturerTextField("J")
            .typeIntoManufacturerTextField("a")
            .typeIntoManufacturerTextField("m")
            .typeIntoManufacturerTextField("is")
            .checkManufacturerTextFieldContains(text: "Jamis")
    }
}
