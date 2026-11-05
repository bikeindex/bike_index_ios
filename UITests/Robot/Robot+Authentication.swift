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
    func startWithSignIn(email: String? = nil, password: String? = nil) throws -> Self {
        try start()
            .signIn(email: email, password: password)
    }

    /// Launch the app and guarantee the session is authenticated as `email` (not just
    /// *any* account), proving it by confirming `bikeLabel` is on the grid.
    @discardableResult
    func startSignedInAs(email: String, password: String, expectingBike bikeLabel: String) throws
        -> Self
    {
        try start()
            .signInAs(email: email, password: password, expectingBike: bikeLabel)
    }

    /// Ensure the session is `email`, verified by the target bike (`bikeLabel`) being on
    /// the grid.
    ///
    /// `signIn` short-circuits when already signed in as *any* account, so a session
    /// left over from a prior test would be mistaken for ours. We only log out when the
    /// bike is missing (wrong account), avoiding an otherwise-flaky always-log-out path.
    @discardableResult
    func signInAs(email: String, password: String, expectingBike bikeLabel: String) throws -> Self {
        try signIn(email: email, password: password)
        if bikeAppears(onScreenLabel: bikeLabel) {
            return self
        }

        Logger.tests.debug(
            "Bike '\(bikeLabel)' absent; logging out and re-authenticating as \(email).")
        try logOut()
        try signIn(email: email, password: password)
        if !bikeAppears(onScreenLabel: bikeLabel) {
            XCTFail(
                "Still not signed in as \(email) after re-auth; bike '\(bikeLabel)' is not visible."
            )
        }
        return self
    }

    /// Wait up to `timeout` seconds for a bike button whose label contains `bikeLabel`.
    func bikeAppears(onScreenLabel bikeLabel: String, timeout: TimeInterval = 15) -> Bool {
        let normalized = bikeLabel.replacingOccurrences(of: "\u{00A0}", with: " ")
        let bike = app.buttons.matching(NSPredicate(format: "label CONTAINS '\(normalized)'"))
        return bike.firstMatch.waitForExistence(timeout: timeout)
    }

    @discardableResult
    func signIn(email: String? = nil, password: String? = nil) throws -> Self {
        // Step 1: A) Open the Sign In Page. Dismiss any OAuth interruption
        // that may be hiding the button before checking for it.
        attemptAppOAuthSecurity()
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

        let timeout: TimeInterval = 180

        let testUsername: String
        let testPassword: String

        if let email, let password {
            testUsername = email
            testPassword = password
        } else {
            // Configure these values in Test-credentials.xcconfig (see adjacent template file)
            let uiTestBundle = try XCTUnwrap(Bundle.uiTests)
            let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)
            testUsername = try XCTUnwrap(infoDictionary["TEST_USERNAME"] as? String)
            testPassword = try XCTUnwrap(infoDictionary["TEST_PASSWORD"] as? String)
        }

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
        let displayedEmailConfirmation = app.webViews.staticTexts[testUsername]
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

    @discardableResult
    func logOut() throws -> Self {
        let timeout: TimeInterval = 15

        let settingsButton = app.buttons["settingsMenu"]
        assert(settingsButton, [.isHittable], timeout: timeout)
        tapWithRetry(settingsButton, attempts: 3, timeout: timeout)

        let signOutButton = app.buttons["signOutButton"]
        assert(signOutButton, [.isHittable], timeout: timeout)
        tapWithRetry(signOutButton, attempts: 3, timeout: timeout)

        // make sure auth page is presented
        let signIn = app.buttons["SignIn"]
        assert(signIn, [.isHittable], timeout: timeout)

        return self
    }

    /// Tap `element`, retrying if it's transiently non-hittable (post-navigation/animation).
    @discardableResult
    private func tapWithRetry(_ element: XCUIElement, attempts: Int, timeout: TimeInterval) -> Bool
    {
        for _ in 0..<attempts {
            if element.waitForExistence(timeout: timeout) && element.isHittable {
                element.tap()
                return true
            }
        }
        element.tap()
        return false
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
