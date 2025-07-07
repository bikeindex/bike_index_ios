//
//  PrivacyPolicyRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class PrivacyPolicyRobot: Robot {
    lazy var generalInformation = app.staticTexts["General Information"]

    @discardableResult
    func backToSettings() -> SettingsRobot {
        back()

        return SettingsRobot(app)
    }

    @discardableResult
    func checkGeneralInformation() -> Self {
        assert(generalInformation, [.exists])
    }
}
