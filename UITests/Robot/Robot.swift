//
//  Robot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/20/25.
//

import OSLog
import XCTest

/// From Robot Pattern for UI testing: https://jhandguy.github.io/posts/robot-pattern-ios/
class Robot {
    private static var defaultTimeout: Double = 60

    var app: XCUIApplication
    var testCase: XCTestCase

    init(
        app: XCUIApplication, testCase: XCTestCase,
        defaultTimeout: TimeInterval = Robot.defaultTimeout
    ) {
        self.app = app
        self.testCase = testCase
        Robot.defaultTimeout = defaultTimeout
    }

    @discardableResult
    func start(timeout: TimeInterval = Robot.defaultTimeout) -> Self {
        app.launch()
        assert(app, [.exists], timeout: timeout)

        return self
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
        testCase.wait(for: [expectation], timeout: timeout)

        return self
    }

}
