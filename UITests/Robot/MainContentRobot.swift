//
//  MainContentRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

/// Robot for testing the main content page.
final class MainContentRobot: Robot {
    lazy var settingsButton = navigationBar.buttons["Settings"]
    lazy var firstBike = app.buttons["Bike 1"]
    lazy var registerBikeButton = app.buttons["Register a bike"]
    lazy var registerStolenBikeButton = app.buttons["Register a stolen bike"]

    @discardableResult
    func tapSettings() -> SettingsRobot {
        tap(settingsButton)

        return SettingsRobot(app)
    }

    @discardableResult
    func tapFirstBike() -> BikeDetailRobot {
        tap(firstBike)

        return BikeDetailRobot(app)
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
}
