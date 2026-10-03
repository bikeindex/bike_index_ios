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

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    func test_main_content_section() throws {
        try MainContentRobot(app)
            .startWithSignIn()

            // Validate By-Status display
            .tapGroupingMenuButton()
            .tapGroupButton(for: Status.found.groupMode)

            .tapGroupingMenuButton()
            // will continue if sort order is already correct and dismsis menu
            .tapGroupSortOrderButton(.forward, returnTo: Status.found.groupMode)

            .check(section: Status.found, isExpanded: true)
            .checkBike(section: Status.found, index: 1, exists: true)
            .tap(section: Status.found)
            .check(section: Status.found, isExpanded: false)
            .checkBike(section: Status.found, index: 1, exists: false)
            .tap(section: Status.found)

            // Validate By-Manufacturer display
            .tapGroupingMenuButton()
            .tapGroupButton(for: Manufacturer.specialized.groupMode)
            .tapGroupingMenuButton()
            .tapGroupSortOrderButton(.forward, returnTo: Manufacturer.specialized.groupMode)

            .check(section: Manufacturer.specialized, isExpanded: true)
            .checkBike(section: Manufacturer.specialized, index: 1, exists: true)
            .tap(section: Manufacturer.specialized)
            .check(section: Manufacturer.specialized, isExpanded: false)
            .checkBike(section: Manufacturer.specialized, index: 1, exists: false)
            .tap(section: Manufacturer.specialized)
    }
}
