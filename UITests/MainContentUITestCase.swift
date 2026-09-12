//
//  MainContentUITestCase.swift
//  BikeIndex
//
//  Created by Jack on 5/1/25.
//

import XCTest

@MainActor
final class MainContentUITestCase: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    func test_main_content_section() throws {
        let robot = MainContentRobot(app)
        try robot
            .startWithSignIn()

            // Switch to by-status grouping, forward sort order
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Status.groupMode)

            .tapGroupingMenuButton()
            // will continue if sort order is already correct and dismiss menu
            .tapGroupSortOrderButton(.forward, returnTo: .byStatus)

        // The sandbox account's bikes change over time, so discover a section
        // that is actually rendered instead of hardcoding one.
        guard let statusSection = robot.discoverFirstSection(in: .byStatus) else {
            XCTFail("No by-status section rendered; does the test account have bikes?")
            return
        }
        checkSectionToggle(robot, statusSection)

        // Switch to by-manufacturer grouping, forward sort order
        robot
            .tapGroupingMenuButton()
            .tapGroupButton(mode: Manufacturer.groupMode)
            .tapGroupingMenuButton()
            .tapGroupSortOrderButton(.forward, returnTo: .byManufacturer)

        guard let manufacturerSection = robot.discoverFirstSection(in: .byManufacturer) else {
            XCTFail("No by-manufacturer section rendered; does the test account have bikes?")
            return
        }
        checkSectionToggle(robot, manufacturerSection)
    }

    /// Checks that `section` starts expanded with its first bike visible, then
    /// collapses it (the bike disappears) and re-expands it (the bike reappears).
    private func checkSectionToggle(_ robot: MainContentRobot, _ section: any MainContentSection) {
        robot
            .check(section: section, isExpanded: true)
            .checkBike(section: section, index: 1, exists: true)
            .tap(section: section)
            .check(section: section, isExpanded: false)
            .checkBike(section: section, index: 1, exists: false)
            .tap(section: section)
    }
}
