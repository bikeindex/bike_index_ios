//
//  Robot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/20/25.
//

import XCTest

/// From Robot Pattern for UI testing: https://jhandguy.github.io/posts/robot-pattern-ios/
class Robot {
    static var defaultTimeout: Double = 60

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

    @discardableResult
    func swipeUp() -> Self {
        app.swipeUp()

        return self
    }
}
