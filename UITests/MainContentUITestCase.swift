//
//  RegisterBikeUITestCase.swift
//  BikeIndex
//
//  Created by Jack on 5/1/25.
//

import XCTest

@MainActor
final class MainContentUITestCase: XCTestCase {
    enum GroupMode: String, CaseIterable, Identifiable, Equatable {
        case byStatus
        case byManufacturer

        var id: String { rawValue }
    }

    let timeout: TimeInterval = 60
    let nonExistenceTimeout: TimeInterval = 1
    let app = XCUIApplication()
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    func test_main_content_section() throws {
        try MainContentRobot(app)
            .startWithSignIn()
            .tapGroupingMenuButton()
            .tapGroupButton(.byStatus)

            .checkSection(.withOwner, isExpanded: true)
            .checkFirstBike(exists: true)
            .tapSectionHeader(.withOwner)
            .checkSection(.withOwner, isExpanded: false)
            .checkFirstBike(exists: false)
            .tapSectionHeader(.withOwner)

            .tapGroupingMenuButton()
            .tapGroupButton(.byManufacturer)

            .checkSection(.jamis, isExpanded: true)
            .checkFirstBike(exists: true)
            .tapSectionHeader(.jamis)
            .checkSection(.jamis, isExpanded: false)
            .checkFirstBike(exists: false)
            .tapSectionHeader(.jamis)
    }
}
