//
//  BikeIndexUITests.swift
//  BikeIndexUITests
//
//  Created by Jack on 11/18/23.
//

import XCTest
import OSLog

@MainActor
final class BikeIndexUITests: XCTestCase {
    let timeout: TimeInterval = 30
    let app = XCUIApplication()
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)

    override func setUpWithError() throws {
        setupSnapshot(app)
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        snapshot("1-error-ocurred")
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
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

        let settings = app.buttons["Settings"]
        _ = settings.waitForExistence(timeout: timeout)
        settings.tap()

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
    func test_acknowledgements_webView_navigation_history() throws {
        app.launch()
        try signIn(app: app)

        // SETUP

        let settings = app.buttons["Settings"]
        _ = settings.waitForExistence(timeout: timeout)
        settings.tap()

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

        let viewAllFiles = app.webViews.buttons["View all files"]
        _ = viewAllFiles.waitForExistence(timeout: timeout)
        viewAllFiles.tap()

        let licenseTxtLink = link(with: "LICENSE.txt")
        let licenseExists = licenseTxtLink.waitForExistence(timeout: timeout)
        if licenseExists {
            licenseTxtLink.tap()
        } else {
            Logger.tests.error("License.txt doesn't exist")
        }
        // PUSH: github.com LICENSE.txt

        // Back should be available after navigating forward but it will _not be available_ because of GitHub
        XCTAssertFalse(backButton.isEnabled)
        // Technically should be false but because GitHub has JS navigation some behaviors are imperfect.
        XCTAssertTrue(forwardButton.isEnabled)

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

        let goToOurSerialPage = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Every bike has a unique"))
        if goToOurSerialPage.element.waitForExistence(timeout: timeout) {
            goToOurSerialPage.element.tap()
        }
    }

    // MARK: - Helpers

    func back() {
        _ = backButton.waitForExistence(timeout: timeout)
        backButton.tap()
    }

    func link(with prefix: String) -> XCUIElement {
        app.links.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).element
    }
}
