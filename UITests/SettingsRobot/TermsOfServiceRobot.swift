//
//  TermsOfServiceRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class TermsOfServiceRobot: Robot {
    lazy var about = app.staticTexts["About our Terms of Service"]

    @discardableResult
    func backToSettings() -> SettingsRobot {
        back()

        return SettingsRobot(app)
    }

    @discardableResult
    func checkAbout() -> Self {
        assert(about, [.exists])
    }
}
