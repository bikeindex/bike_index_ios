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
        try MainContentRobot(app)
            .startWithSignIn()
            .tapFirstBike()
            .tapEditButton()
            .tapViewBikeButton()
            .tapEditButton()
            .back()
    }

    func test_basic_settings_navigation() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapSettings()
            .tapAppIcon()
            .back()
            .tapDebugMenu()
            .back()
            .swipeUp()
            .tapAcknowledgements()
            .back()
            .swipeUp()
            .tapPrivacyPolicy()
            .checkGeneralInformation()
            .back()
            .tapTerms()
            .checkAbout()
            .back()
    }

    /// Just remember that GitHub is running its own navigation control with JavaScript/whatever/replacing the page
    /// so the buttons will behave incorrectly when using GitHub links. (Except for their subdomains).
    #warning("As of 2025-03 GitHub navigation does **NOT** respect WebView history")
    func test_acknowledgements_webView_navigation_history() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            // SETUP
            .tapSettings()
            .swipeUp()
            .tapAcknowledgements()
            .tap_iOS_repo()
            .tapLinkButton()
            // No history is available yet
            .checkBackButton(isEnabled: false)
            .checkForwardButton(isEnabled: false)
            // SUBSTANCE
            // PUSH: bikeindex.org OAuth Applications
            .tapOauthLink()
            .checkDocumentationLink()
            // Wait for the page to finish loading before testing back button
            // Back should be available after navigating forward
            .checkBackButton(isEnabled: true)
            .checkForwardButton(isEnabled: false)
            .tapBackButton()
            .tapViewAllFilesIfNeeded()
            // PUSH: github.com LICENSE.txt
            .tapLicenseTxt()
            // Back should be available after navigating forward but it will _not be available_ because of GitHub
            // .checkBackButton(isEnabled: false)
            // Technically should be false but because GitHub has JS navigation some behaviors are imperfect.
            // .checkForwardButton(isEnabled: true)
            // POP: github.com LICENSE.txt
            .tapBackButton()
            .checkBackButton(isEnabled: false)
            .checkForwardButton(isEnabled: true)
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

        let whatToDoIfYourBikeIStolenPage = app.buttons["What to do if your bike is stolen"]
        _ = whatToDoIfYourBikeIStolenPage.waitForExistence(timeout: timeout)
        whatToDoIfYourBikeIStolenPage.tap()

        back()

        let goToHowToGetYourBikeBackPage = app.buttons["How to get your stolen bike back"]
        _ = goToHowToGetYourBikeBackPage.waitForExistence(timeout: timeout)
        goToHowToGetYourBikeBackPage.tap()

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
