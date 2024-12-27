//
//  BikeIndexAppAccessibilityPreviewTest.swift
//  BikeIndex
//
//  Created by Jack on 12/27/24.
//

import XCTest
import SnapshottingTests
import Snapshotting

class BikeIndexAppAccessibilityPreviewTest: AccessibilityPreviewTest {
    
    override func auditType() -> XCUIAccessibilityAuditType {
        return .all
    }

    override func handle(issue: XCUIAccessibilityAuditIssue) -> Bool {
        return false
    }
}
