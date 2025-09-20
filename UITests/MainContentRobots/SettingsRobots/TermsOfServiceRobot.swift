//
//  TermsOfServiceRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class TermsOfServiceRobot: Robot, NavigatesBackToSettings {
    lazy var about = app.staticTexts["About our Terms of Service"]

    @discardableResult
    func checkAbout() -> Self {
        assert(about, [.exists])
    }
}
