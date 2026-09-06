//
//  WebViewRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

import XCUIAutomation

// TODO: Refactor into base WebViewRobot and subclass for specific web views, like Acknowledgements page in settings.
final class WebViewRobot: Robot {

    /// Used for any link that begins with this value
    enum PagePrefix: String {
        case license = "LICENSE.txt"

        var linkPrefix: String { rawValue }
    }

    /// The configured host must be prepended.
    enum PageSuffix: String {
        case oauth = "/oauth/applications"

        var path: String { rawValue }
    }

    lazy var backButton = app.buttons["WebViewBack"]
    lazy var forwardButton = app.buttons["WebViewForward"]

    @discardableResult
    func checkBackButton(isEnabled: Bool) -> Self {
        check(backButton, isEnabled: isEnabled)
    }

    @discardableResult
    func checkForwardButton(isEnabled: Bool) -> Self {
        check(forwardButton, isEnabled: isEnabled)
    }

    @discardableResult
    func checkDocumentationLink() -> Self {
        assert(link(with: "/documentation"), [.exists])
    }

    @discardableResult
    func navigate(to page: PagePrefix) -> Self {
        // Links may not be hittable if off screen, so check if exists instead before tapping.
        let link = link(with: page.linkPrefix)
        assert(link, [.exists])
        link.tap()

        return self
    }

    @discardableResult
    func navigate(to page: PageSuffix) throws -> Self {
        // Links may not be hittable if off screen, so check if exists instead before tapping.
        let config = try APIConfiguration.uiTestConfig()
        let resolvedUrl = config.host.appending(path: page.path)
        let link = link(with: resolvedUrl.absoluteString)
        assert(link, [.exists])
        link.tap()

        return self
    }

    @discardableResult
    func navigateBack() -> Self {
        tap(backButton)
    }

    @discardableResult
    func tapViewAllFilesIfNeeded(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        // Conditional because iPad has enough space to display LICENSE.txt without tapping "View all files"
        let viewAllFiles = app.webViews.buttons["View all files"]
        if viewAllFiles.waitForExistence(timeout: timeout) {
            viewAllFiles.tap()
        }

        return self
    }

    private func check(_ element: XCUIElement, isEnabled: Bool) -> Self {
        assert(element, [isEnabled ? .isEnabled : .isNotEnabled])
    }

    private func link(with prefix: String) -> XCUIElement {
        app.links.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).element
    }
}
