//
//  BikeIndexUITests.swift
//  UITests
//
//  Created by Jack on 11/18/23.
//

import OSLog
import XCTest

@MainActor
final class BikeIndexUITests: XCTestCase {
    let timeout: TimeInterval = 60
    let app = XCUIApplication()
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    /// Sometimes this fails when a page plainly fails to load, may need to add more resiliency.
    func test_basic_bike_detail_navigation() throws {
        app.launch()
        try signIn(app: app)

        let bike1 = app.buttons["Bike 1"]
        _ = bike1.waitForExistence(timeout: timeout)
        bike1.tap()

        // On-page
        let webViewEdit = app.buttons["Edit"]
        _ = webViewEdit.waitForExistence(timeout: timeout)
        webViewEdit.tap()

        let webViewBikeView = app.links["View Bike"]
        _ = webViewBikeView.waitForExistence(timeout: timeout)
        webViewBikeView.tap()

        _ = webViewEdit.waitForExistence(timeout: timeout)
        webViewEdit.tap()

        back()
    }

    func test_basic_settings_navigation() throws {
        app.launch()
        try signIn(app: app)

        openSettings()

        let appIcon = app.buttons["App Icon"]
        _ = appIcon.waitForExistence(timeout: timeout)
        appIcon.tap()

        back()

        let debugMenu = app.buttons["Debug menu"]
        _ = debugMenu.waitForExistence(timeout: timeout)
        debugMenu.tap()

        back()

        let acknowledgements = app.buttons["Acknowledgements"]
        _ = acknowledgements.waitForExistence(timeout: timeout)
        acknowledgements.tap()

        back()

        app.swipeUp()

        let privacyPolicy = app.buttons["Privacy Policy"]
        _ = privacyPolicy.waitForExistence(timeout: timeout)
        privacyPolicy.tap()

        back()

        let terms = app.buttons["Terms of Service"]
        _ = terms.waitForExistence(timeout: timeout)
        terms.tap()

        back()
    }

    /// Just remember that GitHub is running its own navigation control with JavaScript/whatever/replacing the page
    /// so the buttons will behave incorrectly when using GitHub links. (Except for their subdomains).
    #warning("As of 2025-03 GitHub navigation does **NOT** respect WebView history")
    func test_acknowledgements_webView_navigation_history() throws {
        app.launch()
        try signIn(app: app)

        // SETUP

        openSettings()

        let acknowledgements = app.buttons["Acknowledgements"]
        _ = acknowledgements.waitForExistence(timeout: timeout)
        acknowledgements.tap()

        let iOS_repo = app.collectionViews.cells.element(boundBy: 2)
        _ = iOS_repo.waitForExistence(timeout: timeout)
        iOS_repo.tap()

        let linkButton = app.buttons["Open Repository"]
        _ = linkButton.waitForExistence(timeout: timeout)
        linkButton.tap()

        // No history is available yet
        let backButton = app.buttons["WebViewBack"]
        _ = backButton.waitForExistence(timeout: timeout)
        XCTAssertFalse(backButton.isEnabled)

        let forwardButton = app.buttons["WebViewForward"]
        _ = forwardButton.waitForExistence(timeout: timeout)
        XCTAssertFalse(forwardButton.isEnabled)

        // SUBSTANCE

        let oauthApplicationsLink = link(with: "https://bikeindex.org/oauth/applications")
        _ = oauthApplicationsLink.waitForExistence(timeout: timeout)
        oauthApplicationsLink.tap()
        // PUSH: bikeindex.org OAuth Applications

        let documentationLink = link(with: "/documentation")
        _ = documentationLink.waitForExistence(timeout: timeout)
        // Wait for the page to finish loading before testing back button

        // Back should be available after navigating forward
        XCTAssertTrue(backButton.isEnabled)
        XCTAssertFalse(forwardButton.isEnabled)

        backButton.tap()

        // Conditional because iPad has enough space to display LICENSE.txt without tapping "View all files"
        let viewAllFiles = app.webViews.buttons["View all files"]
        if viewAllFiles.waitForExistence(timeout: timeout) {
            viewAllFiles.tap()
        }

        let licenseTxtLink = link(with: "LICENSE.txt")
        let licenseExists = licenseTxtLink.waitForExistence(timeout: timeout)
        if licenseExists {
            licenseTxtLink.tap()
        } else {
            Logger.tests.error("License.txt doesn't exist")
        }
        // PUSH: github.com LICENSE.txt

        // Back should be available after navigating forward but it will _not be available_ because of GitHub
        // XCTAssertFalse(backButton.isEnabled)
        // Technically should be false but because GitHub has JS navigation some behaviors are imperfect.
        // XCTAssertTrue(forwardButton.isEnabled)

        backButton.tap()
        // POP: github.com LICENSE.txt

        XCTAssertFalse(backButton.isEnabled)
        XCTAssertTrue(forwardButton.isEnabled)
    }

    func test_serial_page_navigation() throws {
        app.launch()
        try signIn(app: app)

        let registerBikeButton = app.buttons["Register a bike"]
        _ = registerBikeButton.waitForExistence(timeout: timeout)
        registerBikeButton.tap()

        let goToOurSerialPage = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Every bike has a unique"))
        if goToOurSerialPage.element.waitForExistence(timeout: timeout) {
            goToOurSerialPage.element.tap()
        } else {
            XCTFail("Expected markdown link at 'go to our serial page'")
        }

        back()
    }

    func test_register_bike_stolen_guide_link() throws {
        app.launch()
        try signIn(app: app)

        let registerBikeButton = app.buttons["Register a stolen bike"]
        _ = registerBikeButton.waitForExistence(timeout: timeout)
        registerBikeButton.tap()

        let goToHowToGetYourBikeBackPage = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "⚠️ How to get your stolen bike back"))
        if goToHowToGetYourBikeBackPage.element.waitForExistence(timeout: timeout) {
            goToHowToGetYourBikeBackPage.element.tap()
        } else {
            XCTFail("Expected markdown link at 'How to get your stolen bike back'")
        }

        back()
    }

    func test_settings_account_pages() throws {
        app.launch()
        try signIn(app: app)

        openSettings()

        button(named: "User Settings")
            .tap()
        let userSettingsConfirmation = app.staticTexts[
            "Give us permission to contact you if we believe your bike has been stolen, even if it isn't marked stolen"
        ]
        _ = userSettingsConfirmation.waitForExistence(timeout: timeout)
        back()

        button(named: "Password")
            .tap()
        let resetPassword = app.staticTexts["Password must be at least 12 characters. Longer is"]
        _ = resetPassword.waitForExistence(timeout: timeout)
        back()

        button(named: "Sharing + Personal Page")
            .tap()
        let sharingPageConfirmation = app.staticTexts["Show Personal Site"]
        _ = sharingPageConfirmation.waitForExistence(timeout: timeout)
        back()

        button(named: "Registration Organization")
            .tap()
        let regOrgsConfirmation = app.staticTexts[
            "Manage the organizations your bikes are registered with."]
        _ = regOrgsConfirmation.waitForExistence(timeout: timeout)
        back()
    }

    // MARK: - Helpers

    func back() {
        _ = backButton.waitForExistence(timeout: timeout)
        backButton.tap()
    }

    func link(with prefix: String) -> XCUIElement {
        app.links.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).element
    }

    func openSettings() {
        let settings = app.buttons["Settings"]
        _ = settings.waitForExistence(timeout: timeout)
        settings.tap()
    }

    func button(named: String) -> XCUIElement {
        let button = app.buttons[named]
        _ = button.waitForExistence(timeout: timeout)
        return button
    }
}

// MARK: - Help button
extension BikeIndexUITests {
    /// Note: UI Tests don't really have a way to enforce that the user is signed-out
    /// to test through the `BikeIndex/AuthView` flow. This omission is passable for this
    /// test because MainContentPage has the same button. But it may need an answer later.
    func testUnauthenticatedHelp() throws {
        app.launch()

        let unauthenticatedHelpButton = app.buttons["Help"]
        _ = unauthenticatedHelpButton.waitForExistence(timeout: timeout)
        unauthenticatedHelpButton.tap()

        back()
    }

    func testMainContentPageHelp() throws {
        app.launch()
        try signIn(app: app)

        let unauthenticatedHelpButton = app.buttons["Help"]
        _ = unauthenticatedHelpButton.waitForExistence(timeout: timeout)
        unauthenticatedHelpButton.tap()

        back()
    }
}
