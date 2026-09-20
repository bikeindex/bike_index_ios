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
    lazy var navigationBarButton = navigationBar.buttons.firstMatch

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

    @discardableResult
    func back(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        tap(navigationBarButton, timeout: timeout)
    }

    /// Scroll an element into the visible region of its scroll container.
    ///
    /// `tap` asserts `isHittable`, which fails for elements that exist but are below
    /// the fold (e.g. a section header in a long grouped list). `scrollToElement` swipes
    /// the primary scroll view upward until the element becomes hittable, and is a
    /// no-op once it already is.
    @discardableResult
    func scrollToElement(
        _ element: XCUIElement,
        timeout: TimeInterval = Robot.defaultTimeout
    ) -> Self {
        // A bounded swipe-up loop. `isHittable` is only true once the element is both
        // visible and not occluded, which is exactly what `tap` requires.
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.2)
        }
        assert(element, [.isHittable], timeout: timeout)
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
