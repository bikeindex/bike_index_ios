//
//  BikeIndexUITests.swift
//  UITests
//
//  Created by Jack on 11/18/23.
//

import XCTest

@MainActor
final class BikeIndexUITests: XCTestCase {
    let app = XCUIApplication()

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
            .navigate(to: .oauth)
            .checkDocumentationLink()
            // Wait for the page to finish loading before testing back button
            // Back should be available after navigating forward
            .checkBackButton(isEnabled: true)
            .checkForwardButton(isEnabled: false)
            .navigateBack()

            .tapViewAllFilesIfNeeded()
            .navigate(to: .license)
            .checkBackButton(isEnabled: true)
            .checkForwardButton(isEnabled: false)
            .navigateBack()

            .checkBackButton(isEnabled: false)
            .checkForwardButton(isEnabled: true)
    }

    func test_serial_page_navigation() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapRegisterBikeButton()
            .tapGoToOurSerialPage()
            .checkSerialPageLoaded()
            .back()
    }

    func test_register_bike_stolen_guide_link() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapRegisterStolenBikeButton()
            .checkWhatToDoPageLoads()
            .checkHowToPageLoads()
    }

    func test_settings_account_pages() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapSettings()

            .tapUserSettings()
            .checkTextExists(
                "Give us permission to contact you if we believe your bike has been stolen,"
            )
            .back()

            .tapPassword()
            .checkTextExists("Password must be at least 12 characters. Longer is")
            .back()

            .tapSharingAndPersonalPage()
            .checkTextExists("Show Personal Site")
            .back()

            .tapRegistrationOrganization()
            .checkTextExists("Manage the organizations your bikes are registered with.")
            .back()
    }
}

// MARK: - Help button
extension BikeIndexUITests {
    /// Note: UI Tests don't really have a way to enforce that the user is signed-out
    /// to test through the `BikeIndex/AuthView` flow. This omission is passable for this
    /// test because MainContentPage has the same button. But it may need an answer later.
    func testUnauthenticatedHelp() throws {
        MainContentRobot(app)
            .start()
            .tapHelpButton()
            .back()
    }

    func testMainContentPageHelp() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapHelpButton()
            .back()
    }
}
