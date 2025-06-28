//
//  Robot+Authentication.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/20/25.
//

import OSLog
import XCTest

extension Robot {
    @discardableResult
    func startWithSignIn() throws -> Self {
        start()
        try signIn()

        return self
    }

    // TODO: Refactor method to use Robot pattern
    @discardableResult
    func signIn() throws -> Self {
        // Step 1: Open the Sign In Page
        let signIn = app.buttons["SignIn"]
        let result = signIn.waitForExistence(timeout: 2)

        guard result else {
            Logger.tests.debug("Already signed-in, skipping UI-test sign-in.")
            return self
        }

        signIn.tap()

        // Try to tap Authorize __if it exists__, continue if it is absent.
        attemptOAuthAuthorize()

        let timeout: TimeInterval = 120

        // Configure these values in Test-credentials.xcconfig (see adjacent template file)
        let uiTestBundle = try XCTUnwrap(Bundle(identifier: "org.bikeindex.UITests"))
        let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)
        let testUsername = try XCTUnwrap(infoDictionary["TEST_USERNAME"] as? String)
        let testPassword = try XCTUnwrap(infoDictionary["TEST_PASSWORD"] as? String)

        // Step 2: Fill credentials and proceed
        let usernameField = app.webViews.firstMatch.textFields["Email"]
        if usernameField.waitForExistence(timeout: timeout) {
            usernameField.tap()
            usernameField.typeText(testUsername)
        } else {
            XCTFail("Couldn't find email field")
        }
        let passwordField = app.webViews.firstMatch.secureTextFields["Password"]
        if passwordField.waitForExistence(timeout: timeout) {
            passwordField.tap()
            passwordField.typeText(testPassword)
        }

        let loginButton = app.webViews.firstMatch.buttons["Log in"]
        _ = loginButton.waitForExistence(timeout: timeout)
        loginButton.tap()

        // Step 3: Make sure that this OAuth Application is authorized.
        authorizeOAuthApplication()

        return self
    }

    private func attemptOAuthAuthorize() {
        let timeout: TimeInterval = 10

        /// If the Authorized Applications ever lapses (https://bikeindex.org/oauth/authorized_applications) then
        /// the CI runner will begin to fail tests and should have this prompt in the sign-in page.
        let guardAgainstAuthorizationRequired = app.webViews.firstMatch.staticTexts[
            "AUTHORIZATION REQUIRED"]
        if guardAgainstAuthorizationRequired.waitForExistence(timeout: timeout) {
            let authorizeButton = app.webViews.firstMatch.buttons["Authorize"]
            if authorizeButton.waitForExistence(timeout: timeout) {
                authorizeButton.tap()
                authorizeButton.tap()
            }
        }
    }

    private func authorizeOAuthApplication() {
        let timeout: TimeInterval = 10

        /// If the Authorized Applications ever lapses (https://bikeindex.org/oauth/authorized_applications) then
        /// the CI runner will begin to fail tests and should have this prompt in the sign-in page.
        let guardAgainstAuthorizationRequired = app.webViews.firstMatch.staticTexts[
            "AUTHORIZATION REQUIRED"]
        guardAgainstAuthorizationRequired.waitForNonExistence(timeout: timeout)

        let authorizeButton = app.webViews.firstMatch.buttons["Authorize"]
        if authorizeButton.waitForExistence(timeout: timeout) {
            authorizeButton.tap()
            authorizeButton.tap()
        }
    }
}
