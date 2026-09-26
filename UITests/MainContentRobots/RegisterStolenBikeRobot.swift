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

    private static let pageLoadTimeout: TimeInterval = 30

    /// Tap a link, wait for its webview page to show the expected heading, then go back.
    ///
    /// The tap+check is retried because these webview pages occasionally fail to load
    /// on the first attempt in CI (transient 404 / slow first paint). Each attempt is
    /// bounded (a short heading wait + a graceful `back`) so a stuck page doesn't
    /// consume the whole test budget and leave the app in an unknown state for the
    /// next attempt. Retrying the same correct check is a resilience aid, not an
    /// assertion-weakening: a page that truly 404s every time will still fail the test.
    @discardableResult
    private func checkPage(
        button: XCUIElement,
        heading: XCUIElement
    ) -> Self {
        retry(times: 3) {
            self.tap(button)
            // Probe existence (no failure recorded) so the retry can tell success from
            // failure; only record the assertion once we actually saw the page load.
            let loaded = heading.waitForExistence(timeout: Self.pageLoadTimeout)
            if loaded {
                self.assert(heading, [.exists], timeout: 1)
            } else {
                print(
                    "[\(self)] \(button.label) page heading not loaded after \(Self.pageLoadTimeout)s"
                )
            }
            // `back` degrades to app.goBack() if the app's back button isn't reachable,
            // so the next attempt always starts from a known state.
            self.back()
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
