//
//  WebViewRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

import XCUIAutomation

// TODO: Refactor into base WebViewRobot and subclass for specific web views, like Acknowledgements page in settings.
final class WebViewRobot: Robot {
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
    func tapOauthLink() -> Self {
        tapLink(link(with: "https://bikeindex.org/oauth/applications"))
    }

    @discardableResult
    func tapBackButton() -> Self {
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

    @discardableResult
    func tapLicenseTxt() -> Self {
        tapLink(link(with: "LICENSE.txt"))
    }

    private func check(_ element: XCUIElement, isEnabled: Bool) -> Self {
        assert(element, [isEnabled ? .isEnabled : .isNotEnabled])
    }

    /// Links may not be hittable if off screen, so check if exists instead before tapping.
    private func tapLink(_ link: XCUIElement) -> Self {
        assert(link, [.exists])
        link.tap()

        return self
    }

    private func link(with prefix: String) -> XCUIElement {
        app.links.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).element
    }
}
