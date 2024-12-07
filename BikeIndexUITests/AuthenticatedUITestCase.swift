//
//  AuthenticatedUITestCase.swift
//  BikeIndexUITests
//
//  Created by Jack on 12/4/24.
//

import XCTest
import OSLog

extension XCTestCase {
    func signIn(app: XCUIApplication) throws {
        // Step 1: Open the Sign In Page
        let signIn = app.buttons["SignIn"]
        let result = signIn.waitForExistence(timeout: 2)

        guard result else {
            Logger.tests.debug("Already signed-in, skipping UI-test sign-in.")
            return
        }

        signIn.tap()

        let uiTestBundle = try XCTUnwrap(Bundle(identifier: "org.bikeindex.BikeIndexUITests"))
        let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)
        let testUsername = try XCTUnwrap(infoDictionary["TEST_USERNAME"] as? String)
        let testPassword = try XCTUnwrap(infoDictionary["TEST_PASSWORD"] as? String)

        // Step 2: Fill credentials and proceed
        let usernameField = app.webViews.firstMatch.textFields["Email"]
        if usernameField.waitForExistence(timeout: 2) {
            usernameField.tap()
            usernameField.typeText(testUsername)
        } else {
            XCTFail("Couldn't find email field")
        }
        let passwordField = app.webViews.firstMatch.secureTextFields["Password"]
        if passwordField.waitForExistence(timeout: 2) {
            passwordField.tap()
            passwordField.typeText(testPassword)
        }

        let loginButton = app.webViews.firstMatch.buttons["Log in"]
        _ = loginButton.waitForExistence(timeout: 2)
        loginButton.tap()
    }

}