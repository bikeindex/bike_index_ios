//
//  PrivacyPolicyRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class PrivacyPolicyRobot: Robot, NavigatesBackToSettings {
    lazy var generalInformation = app.staticTexts["General Information"]

    @discardableResult
    func checkGeneralInformation() -> Self {
        assert(generalInformation, [.exists])
    }
}
