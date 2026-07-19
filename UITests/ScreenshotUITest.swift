//
//  ScreenshotUITest.swift
//  BikeIndex
//
//  Test class for automated app store screenshot capture.
//  Each method navigates to a key screen and captures screenshots.

import XCTest
// import ./fastlane/SnapshotHelper

extension Robot {
    /// Capture screenshots for App Store Connect releases
    /// - Parameter name: Unique name of the screenshot
    /// - Returns: Attachment for upload
    @MainActor
    func captureSnapshot(named name: String) {
        snapshot(name)
    }
}

/// ScreenshotUITest is within the UITests target, rather than an independent target,
/// to ensure it always compiles. A separate target is too easy to miss.
/// The separation of continuous integration tests vs. release screenshots
/// is distinguished in AllTests.xctestPlan vs. ReleaseScreenshots.xctestplan.
@MainActor
public final class ScreenshotUITest: XCTestCase {

    let app = XCUIApplication()

    override public func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        setupSnapshot(app, waitForAnimations: true)
        app.launchEnvironment["EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] = "1"
    }

    // MARK: - 1. Main Content Page

    public func test_1_screenshot_main_content_page() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .captureSnapshot(named: "1-main-content")
    }

    // MARK: - 2. Register Bike Page

    public func test_2_screenshot_register_bike() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapRegisterBikeButton()
            .captureSnapshot(named: "2-register-bike-initial")
    }

    // MARK: - 3. Sticker Details Page (A40340)

    public func test_3_screenshot_details_page_a40340() throws {
        XCUIDevice.shared.orientation = .portrait

        UniversalLinksRobot(app)
            .start()
            .openLink()
            .checkStickerHeader()
            .captureSnapshot(named: "3-sticker-details")
    }
}
