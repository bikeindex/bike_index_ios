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
        app.launch()
        try signIn(app: app)

        let groupingMenuButton = app.navigationBars.buttons["Change how bikes are grouped."]
        _ = groupingMenuButton.waitForExistence(timeout: timeout)
        // https://stackoverflow.com/a/33534187/178805
        if !groupingMenuButton.isHittable {
            let coordinate: XCUICoordinate = groupingMenuButton.coordinate(
                withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        } else {
            groupingMenuButton.tap()
        }

        let groupByStatusButton = app.buttons[GroupMode.byStatus.rawValue]
        _ = groupByStatusButton.waitForExistence(timeout: timeout)
        groupByStatusButton.tap()

        let sectionHeaderStatusWithOwner = app.buttons["Section toggle With Owner"]
        _ = sectionHeaderStatusWithOwner.waitForExistence(timeout: timeout)
        XCTAssertEqual(sectionHeaderStatusWithOwner.value as? String, "Expanded")

        let bike1_before_status_collapse_exists = app.buttons["Bike 1"]
            .waitForExistence(timeout: timeout)
        XCTAssertTrue(bike1_before_status_collapse_exists)

        //
        sectionHeaderStatusWithOwner.tap()
        XCTAssertEqual(sectionHeaderStatusWithOwner.value as? String, "Collapsed")

        //
        let bike1_after_status_expand_does_not_exist = app.buttons["Bike 1"]
            .waitForNonExistence(timeout: nonExistenceTimeout)
        XCTAssertTrue(bike1_after_status_expand_does_not_exist)

        // Expand status group again
        sectionHeaderStatusWithOwner.tap()

        // Change grouping
        // https://stackoverflow.com/a/33534187/178805
        if !groupingMenuButton.isHittable {
            let coordinate: XCUICoordinate = groupingMenuButton.coordinate(
                withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        } else {
            groupingMenuButton.tap()
        }
        let groupByManufacturerButton = app.buttons[GroupMode.byManufacturer.rawValue]
        _ = groupByManufacturerButton.waitForExistence(timeout: timeout)
        groupByManufacturerButton.tap()

        let sectionHeaderJamis = app.buttons["Section toggle Jamis"]
        _ = sectionHeaderJamis.waitForExistence(timeout: timeout)
        XCTAssertEqual(sectionHeaderJamis.value as? String, "Expanded")

        let bike1_before_manufacturer_collapse_exists = app.buttons["Bike 1"]
            .waitForExistence(timeout: timeout)
        XCTAssertTrue(bike1_before_manufacturer_collapse_exists)

        //
        sectionHeaderJamis.tap()
        XCTAssertEqual(sectionHeaderJamis.value as? String, "Collapsed")

        let bike1_after_manufacturer_expand_does_not_exist = app.buttons["Bike 1"]
            .waitForNonExistence(timeout: nonExistenceTimeout)
        XCTAssertTrue(bike1_after_manufacturer_expand_does_not_exist)

        // Expand manufacturer group again
        sectionHeaderJamis.tap()

    }
}
