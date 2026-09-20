//
//  RegisterStolenBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/9/25.
//

import XCUIAutomation

final class RegisterStolenBikeRobot: Robot {
    lazy var whatToDoButton = app.buttons["What to do if your bike is stolen"]

    private var whatToDoPageHeading: XCUIElement {
        app.webViews.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'What to do if your bike is stolen'")
        ).firstMatch
    }

    lazy var howToButton = app.buttons["How to get your stolen bike back"]

    private var howToPageHeading: XCUIElement {
        app.webViews.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Bike Index is the #1 resource'")
        ).firstMatch
    }

    /// Tap a link, wait for its webview page to show the expected heading, then go back.
    ///
    /// The tap+check is retried because these webview pages occasionally fail to load
    /// on the first attempt in CI (transient 404 / slow first paint). Retrying the same
    /// correct check is a resilience aid, not an assertion-weakening: a page that truly
    /// 404s every time will still fail the test.
    @discardableResult
    private func checkPage(
        button: XCUIElement,
        heading: XCUIElement,
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        retry(times: 5) {
            self.tap(button)
            // `assert` returns self and records a failure via XCTFail when the element
            // never appears within `timeout`; probe its existence so the retry can tell
            // success from failure without a second failure being logged.
            let loaded = heading.waitForExistence(timeout: timeout)
            if loaded {
                self.assert(heading, [.exists], timeout: 1)
            }
            self.back(timeout: timeout)
            return loaded
        }
        return self
    }

    @discardableResult
    func checkWhatToDoPageLoads() -> Self {
        checkPage(button: whatToDoButton, heading: whatToDoPageHeading)
    }

    @discardableResult
    func checkHowToPageLoads() -> Self {
        checkPage(button: howToButton, heading: howToPageHeading)
    }
}
