//
//  MainContentRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

import XCUIAutomation

/// Abstract section header to support both GroupMode.byStatus and GroupMode.byManufacturer sections on MainContentPage.
protocol MainContentSection: RawRepresentable {
    /// The section's Bikes accessibility identifier for this section
    var headerIdentifier: String { get }
    /// The section's substring used as part of Bikes accessibility identifier in this section
    var bikeIdentifier: String { get }
}

/// Partial clone of `MainContentPage.ViewModel.GroupMode` because UITests don't import BikeIndex module (and all its dependencies)
enum GroupMode: String {
    case byStatus
    case byManufacturer
}

enum Manufacturer: String, MainContentSection {
    case specialized
    case raleigh
    case intense

    var headerIdentifier: String { "Section toggle \(rawValue.capitalized)" }
    var bikeIdentifier: String { rawValue.capitalized }
    static var groupMode: GroupMode { .byManufacturer }
}

/// Partial clone of `BikeStatus` because UITests don't import BikeIndex module (and all its dependencies)
enum Status: String, MainContentSection {
    case withOwner = "with owner"
    case found
    case unregisteredParkingNotification = "unregistered"

    var headerIdentifier: String { rawValue.capitalized }
    var bikeIdentifier: String { rawValue.capitalized }
    static var groupMode: GroupMode { .byStatus }
}

// MARK: -

/// Robot for testing the main content page.
final class MainContentRobot: Robot {
    lazy var settingsButton = navigationBar.buttons["Settings"]
    lazy var helpButton = navigationBar.buttons["Help"]
    lazy var registerBikeButton = app.buttons["Register a bike"]
    lazy var registerStolenBikeButton = app.buttons["Register a stolen bike"]

    // Grouping
    lazy var groupingMenuButton = app.navigationBars.buttons["Change how bikes are grouped."]
    lazy var groupByStatusButton = app.buttons[GroupMode.byStatus.rawValue]
    lazy var groupByManufacturerButton = app.buttons[GroupMode.byManufacturer.rawValue]
    // Sorting
    /// Aka SortOrder.forward
    lazy var sortOrderDescending = app.buttons["sortOrder-arrow.down"]
    /// Aka SortOrder.reverse
    lazy var sortOrderAscending = app.buttons["sortOrder-arrow.up"]

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
        let firstBike = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'Bike' AND identifier ENDSWITH '1'")
        ).firstMatch
        tap(firstBike)

        return BikeDetailRobot(app)
    }

    @discardableResult
    func checkBike(section: any MainContentSection, index: Int, exists: Bool) -> Self {
        let bike = app.buttons["Bike \(section.bikeIdentifier)-\(index)"]
        assert(bike, [exists ? .exists : .doesNotExist])
        return self
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

    /// Tap in the center of the overall application to dismiss any lingering Grouping Menu (in the top trailing toolbar)
    @discardableResult
    func dismissGroupingMenuButton() -> Self {
        let timeout: TimeInterval = 5
        if groupingMenuButton.waitForExistence(timeout: timeout) {
            let coordinate: XCUICoordinate = app.coordinate(withNormalizedOffset: .zero)
            print("@@ \(#function) will tap coordinate \(coordinate)")
            coordinate.tap()
        }
        return self
    }

    @discardableResult
    func tapGroupButton(for groupMode: GroupMode) -> Self {
        switch groupMode {
        case .byStatus:
            tap(groupByStatusButton)
        case .byManufacturer:
            tap(groupByManufacturerButton)
        }
    }

    /// Must call ``tapGroupingMenuButton()`` before invoking this function.
    /// - Parameters:
    ///   - sortOrder: The desired sort order, will use `returnTo` if this sort is already selected.
    ///   - returnTo: We can't really dismiss this nicely in UITests without tapping something, so `returnTo` is the GroupMode that will be tapped in order to close this menu.
    @discardableResult
    func tapGroupSortOrderButton(_ sortOrder: SortOrder, returnTo groupMode: GroupMode) -> Self {
        let timeout: TimeInterval = 5
        switch sortOrder {
        case .forward:
            // _change to_ ascending/reverse, if not using that already
            if sortOrderAscending.waitForExistence(timeout: timeout) {
                tap(sortOrderAscending)
            } else {
                tapGroupButton(for: groupMode)
            }
        case .reverse:
            // _change to_ descending/forward, if not using that already
            if sortOrderDescending.waitForExistence(timeout: timeout) {
                tap(sortOrderDescending)
            } else {
                tapGroupButton(for: groupMode)
            }
        }
        return self
    }

    @discardableResult
    func check(section sectionHeader: any MainContentSection, isExpanded: Bool) -> Self {
        assert(
            app.buttons[sectionHeader.headerIdentifier],
            [.containsValue(isExpanded ? "Expanded" : "Collapsed")])
    }

    @discardableResult
    func tap(section sectionHeader: any MainContentSection) -> Self {
        tap(app.buttons[sectionHeader.headerIdentifier])
    }
}
