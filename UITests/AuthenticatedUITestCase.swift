//
//  AuthenticatedUITestCase.swift
//  UITests
//
//  Created by Jack on 12/4/24.
//

import OSLog
import XCTest

// TODO: Remove after refactoring UI tests to Robot pattern
extension XCTestCase {
    @MainActor
    func signIn(app: XCUIApplication) throws {
        try Robot(app).signIn()
    }

}
