//
//  NavigatesBackToSettings.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

/// Overrides back() method to return SettingsRobot.
protocol NavigatesBackToSettings: Robot {
    func back() -> SettingsRobot
}

extension NavigatesBackToSettings {
    @discardableResult
    func back() -> SettingsRobot {
        back()

        return SettingsRobot(app)
    }
}
