//
//  BikeIndexUITests.swift
//  BikeIndexUITests
//
//  Created by Jack on 11/18/23.
//

import XCTest
import OSLog

final class BikeIndexUITests: XCTestCase {
    let timeout: TimeInterval = 10
    let app = XCUIApplication()
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func test_basic_bike_detail_navigation() throws {
        app.launch()
        signin()

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
        signin()

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

    func test_acknowledgements_webView_navigation_history() throws {
        app.launch()
        signin()

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

        let licenseTxt = link(with: "LICENSE.txt")
        licenseTxt.waitForExistence(timeout: timeout)
        licenseTxt.tap()

        let learnMoreLicenses = link(with: "Learn more about repository")
        learnMoreLicenses.waitForExistence(timeout: timeout)
        learnMoreLicenses.tap()

        Logger.tests.debug("End result reached, available links are \(self.app.links, privacy: .public)")
        Logger.tests.debug("End result reached, available links are \(self.app.links, privacy: .public)")
    }

    // MARK: - Helpers

    func back() {
        _ = backButton.waitForExistence(timeout: timeout)
        backButton.tap()
    }

    func signin() {
        let signIn = app.buttons["SignIn"]
        let result = signIn.waitForExistence(timeout: 2)
        if result {
            signIn.tap()
        }
    }

    func link(with prefix: String) -> XCUIElement {
        app.links.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).element
    }
}
