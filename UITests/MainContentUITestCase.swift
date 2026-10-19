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
            .tapGroupButton(for: Status.unregisteredParkingNotification.groupMode)

            .tapGroupingMenuButton()
            // will continue if sort order is already correct and dismsis menu
            .tapGroupSortOrderButton(
                .forward, returnTo: Status.unregisteredParkingNotification.groupMode
            )

            .check(section: Status.unregisteredParkingNotification, isExpanded: true)
            .checkBike(section: Status.unregisteredParkingNotification, index: 1, exists: true)
            .tap(section: Status.unregisteredParkingNotification)
            .check(section: Status.unregisteredParkingNotification, isExpanded: false)
            .checkBike(section: Status.unregisteredParkingNotification, index: 1, exists: false)
            .tap(section: Status.unregisteredParkingNotification)

            // Validate By-Manufacturer display
            .tapGroupingMenuButton()
            .tapGroupButton(for: Manufacturer.rockyMountain.groupMode)
            .tapGroupingMenuButton()
            .tapGroupSortOrderButton(.forward, returnTo: Manufacturer.rockyMountain.groupMode)

            .check(section: Manufacturer.rockyMountain, isExpanded: true)
            .checkBike(section: Manufacturer.rockyMountain, index: 1, exists: true)
            .tap(section: Manufacturer.rockyMountain)
            .check(section: Manufacturer.rockyMountain, isExpanded: false)
            .checkBike(section: Manufacturer.rockyMountain, index: 1, exists: false)
            .tap(section: Manufacturer.rockyMountain)
    }
}
