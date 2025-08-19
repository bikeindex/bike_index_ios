//
//  WebViewRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

import XCUIAutomation

// TODO: Refactor into base WebViewRobot and subclass for specific web views, like Acknowledgements page in settings.
final class WebViewRobot: Robot {

    enum Page: String {
        case oauth = "https://bikeindex.org/oauth/applications"
        case license = "LICENSE.txt"

        var linkPrefix: String { rawValue }
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
    func navigate(to page: Page) -> Self {
        // Links may not be hittable if off screen, so check if exists instead before tapping.
        let link = link(with: page.linkPrefix)
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
