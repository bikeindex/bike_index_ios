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
        try start()
            .signIn()
    }

    @discardableResult
    func signIn() throws -> Self {
        // Step 1: A) Open the Sign In Page
        let signIn = app.buttons["SignIn"]
        let result = signIn.waitForExistence(timeout: 2)

        guard result else {
            Logger.tests.debug("Already signed-in, skipping UI-test sign-in.")
            return self
        }

        signIn.tap()

        // Step 1: B) Catch any interruptions atop the OAuth authorization
        attemptAppOAuthSecurity()

        // Step 1: C) Try to tap Authorize, continue if it is absent.
        attemptOAuthAuthorize()

        let timeout: TimeInterval = 120

        // Configure these values in Test-credentials.xcconfig (see adjacent template file)
        let uiTestBundle = try XCTUnwrap(Bundle(identifier: "org.bikeindex.UITests"))
        let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)
        let testUsername = try XCTUnwrap(infoDictionary["TEST_USERNAME"] as? String)
        let testPassword = try XCTUnwrap(infoDictionary["TEST_PASSWORD"] as? String)

        // Step 2: A) Enter email
        let usernameField = app.webViews.firstMatch.textFields["Email"]
        if usernameField.waitForExistence(timeout: timeout) {
            usernameField.tap()
            usernameField.typeText(testUsername)
        } else {
            XCTFail("Couldn't find email field")
        }

        // Step 2: B) Continue
        let continueButton = app.webViews.firstMatch.buttons["Continue"]
        _ = continueButton.waitForExistence(timeout: timeout)
        continueButton.tap()

        // Step 3: A) Ensure password page is ready
        // Now that we're using a two-step email page -> password page flow,
        // the UITests need a stronger signal that the password page is ready.
        let displayedEmailConfirmation = app.webViews.textFields[testUsername]
        _ = displayedEmailConfirmation.waitForExistence(timeout: timeout)

        // Step 3: B) Enter password
        let passwordField = app.webViews.firstMatch.secureTextFields["Password"]
        if passwordField.waitForExistence(timeout: timeout) {
            passwordField.tap()
            passwordField.typeText(testPassword)
        }

        let loginButton = app.webViews.firstMatch.buttons["Log in"]
        _ = loginButton.waitForExistence(timeout: timeout)
        loginButton.tap()

        // Step 4: Resolve the "insecure authorization" prompt if present
        attemptAppOAuthSecurity()

        // Step 5: Make sure that this OAuth Application is authorized.
        authorizeOAuthApplication()

        return self
    }

    /// If OAuth Authorization is required, there _may also_ be a security
    /// warning overlay for authorizations that are new to this user + OAuth app
    private func attemptAppOAuthSecurity() {
        let timeout: TimeInterval = 10
        let appOAuthSecurityRequired = app.otherElements["New authorization"]
        let close = appOAuthSecurityRequired.buttons["Close"]
        if appOAuthSecurityRequired.waitForExistence(timeout: timeout),
            appOAuthSecurityRequired.elementType == .other, close.waitForExistence(timeout: timeout)
        {
            close.tap()
        }
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
