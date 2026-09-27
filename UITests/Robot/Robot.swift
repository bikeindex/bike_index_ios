//
//  Robot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/20/25.
//

import XCTest

/// From Robot Pattern for UI testing: https://jhandguy.github.io/posts/robot-pattern-ios/
open class Robot {
    static var defaultTimeout: Double = 120

    var app: XCUIApplication

    lazy var navigationBar = app.navigationBars.firstMatch

    init(_ app: XCUIApplication, defaultTimeout: TimeInterval = Robot.defaultTimeout) {
        self.app = app
        Robot.defaultTimeout = defaultTimeout
    }

    @discardableResult
    func start(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        app.launch()
        return assert(app, [.exists], timeout: timeout)
    }

    @discardableResult
    func tap(_ element: XCUIElement, timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        assert(element, [.isHittable], timeout: timeout)
        element.tap()

        return self
    }

    @discardableResult
    func assert(
        _ element: XCUIElement, _ predicates: [Predicate],
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: predicates.map { $0.format }.joined(separator: " AND ")),
            object: element)
        guard XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed else {
            XCTFail(
                "[\(self)] Element \(element.description) did not fulfill expectation: \(predicates.map { $0.format })"
            )
            return self
        }

        return self
    }

    /// Tap the app's own navigation bar back button (the app's chrome, not any
    /// button inside a webview). Uses a short timeout: on a webview-backed page the
    /// app's back button may not be hittable, and blocking on it (the old default
    /// of 120s) is exactly what made retries useless — the app would sit mid-page and
    /// every subsequent retry re-tapped the wrong/stale element. When the button
    /// isn't reachable we log and return so the caller can decide what to do (e.g.
    /// retry the whole test via the test plan's maximumTestRepetitions).
    @discardableResult
    func back(timeout: TimeInterval = 10) -> Self {
        let button = navigationBar.buttons.firstMatch
        if button.waitForExistence(timeout: 2), button.isHittable {
            button.tap()
            return self
        }
        print("[\(self)] warning: nav back button not hittable in 2s")
        return self
    }

    /// Run an action a bounded number of times, stopping as soon as it succeeds.
    ///
    /// Useful for webview-backed pages that occasionally fail to load on the first
    /// attempt (transient 404s, slow first paint). The action is expected to signal
    /// success by returning `true`; a persistent failure still fails the test because
    /// the final attempt is surfaced to XCTest. This is deliberately *not* a way to
    /// weaken an assertion — it retries the same correct check.
    @discardableResult
    func retry(
        times: Int = 3,
        _ action: @escaping () -> Bool
    ) -> Self {
        for attempt in 1...times {
            if action() {
                return self
            }
            if attempt < times {
                print("[\(self)] \(#function) attempt \(attempt)/\(times) failed, retrying")
            }
        }
        XCTFail("[\(self)] \(#function) action did not succeed after \(times) attempts")
        return self
    }

    @discardableResult
    func swipeUp() -> Self {
        app.swipeUp()

        return self
    }

    @discardableResult
    func finishWebViewLoading(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        // also known as SwiftUI.ProgressView
        let activityIndicator = app.activityIndicators["navigableWebViewProgressView"]
        assert(activityIndicator, [.doesNotExist], timeout: timeout)
        return self
    }

    @discardableResult
    func finishRestoringSession(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        // The WelcomeView shows a ProgressView + "Logging in…" while the app
        // attempts to restore a session from a persisted (possibly expired) keychain token.
        // Wait for it to disappear before proceeding with sign-in.
        let restoringIndicator = app.otherElements["restoringSession-loggingIn-indicator"]
        assert(restoringIndicator, [.doesNotExist], timeout: timeout)
        return self
    }

    @discardableResult
    func ensureSandboxReviewAppBannerAbsent() -> Self {
        let reviewAppBanner = app.staticTexts["Sandbox"]
        assert(reviewAppBanner, [.doesNotExist], timeout: 10)
        return self
    }
}
