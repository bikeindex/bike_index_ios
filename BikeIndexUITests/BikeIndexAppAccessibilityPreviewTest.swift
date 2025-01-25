//
//  BikeIndexAppAccessibilityPreviewTest.swift
//  BikeIndex
//
//  Created by Jack on 12/27/24.
//

import Snapshotting
import SnapshottingTests
import XCTest

// TODO: Fix failing tests
class BikeIndexAppAccessibilityPreviewTest: AccessibilityPreviewTest {

    override func auditType() -> XCUIAccessibilityAuditType {
        return .all
    }

    override func handle(issue: XCUIAccessibilityAuditIssue) -> Bool {
        return false
    }
}
