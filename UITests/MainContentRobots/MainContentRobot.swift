//
//  MainContentRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

import XCUIAutomation

/// Robot for testing the main content page.
final class MainContentRobot: Robot {
    enum GroupMode: String {
        case byStatus
        case byManufacturer
    }

    enum SectionHeader: String {
        case withOwner = "Section toggle With Owner"
        case jamis = "Section toggle Jamis"
    }

    lazy var settingsButton = navigationBar.buttons["Settings"]
    lazy var helpButton = navigationBar.buttons["Help"]
    lazy var firstBike = app.buttons["Bike 1"]
    lazy var registerBikeButton = app.buttons["Register a bike"]
    lazy var registerStolenBikeButton = app.buttons["Register a stolen bike"]

    // Grouping
    lazy var groupingMenuButton = app.navigationBars.buttons["Change how bikes are grouped."]
    lazy var groupByStatusButton = app.buttons[GroupMode.byStatus.rawValue]
    lazy var groupByManufacturerButton = app.buttons[GroupMode.byManufacturer.rawValue]

    @discardableResult
    func tapSettings() -> SettingsRobot {
        tap(settingsButton)

        return SettingsRobot(app)
    }

    @discardableResult
    func tapHelpButton() -> Self {
        tap(helpButton)
    }

    @discardableResult
    func tapFirstBike() -> BikeDetailRobot {
        tap(firstBike)

        return BikeDetailRobot(app)
    }

    @discardableResult
    func checkFirstBike(exists: Bool) -> Self {
        assert(firstBike, [exists ? .exists : .doesNotExist])
    }

    @discardableResult
    func tapRegisterBikeButton() -> RegisterBikeRobot {
        tap(registerBikeButton)

        return RegisterBikeRobot(app)
    }

    @discardableResult
    func tapRegisterStolenBikeButton() -> RegisterStolenBikeRobot {
        tap(registerStolenBikeButton)

        return RegisterStolenBikeRobot(app)
    }

    @discardableResult
    func tapGroupingMenuButton() -> Self {
        assert(groupingMenuButton, [.exists])
        // https://stackoverflow.com/a/33534187/178805
        if !groupingMenuButton.isHittable {
            let coordinate: XCUICoordinate = groupingMenuButton.coordinate(
                withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        } else {
            groupingMenuButton.tap()
        }

        return self
    }

    @discardableResult
    func tapGroupButton(_ groupMode: GroupMode) -> Self {
        switch groupMode {
        case .byStatus:
            tap(groupByStatusButton)
        case .byManufacturer:
            tap(groupByManufacturerButton)
        }
    }

    @discardableResult
    func checkSection(_ sectionHeader: SectionHeader, isExpanded: Bool) -> Self {
        assert(
            app.buttons[sectionHeader.rawValue],
            [.containsValue(isExpanded ? "Expanded" : "Collapsed")])
    }

    @discardableResult
    func tapSectionHeader(_ sectionHeader: SectionHeader) -> Self {
        tap(app.buttons[sectionHeader.rawValue])
    }
}
