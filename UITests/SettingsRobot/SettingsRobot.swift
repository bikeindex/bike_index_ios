//
//  SettingsRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

/// Robot for testing the settings page.
final class SettingsRobot: Robot {
    lazy var appIcon = app.buttons["App Icon"]
    lazy var debugMenu = app.buttons["Debug menu"]
    lazy var acknowledgements = app.buttons["Acknowledgements"]
    lazy var privacyPolicy = app.buttons["Privacy Policy"]
    lazy var terms = app.buttons["Terms of Service"]

    @discardableResult
    func tapAppIcon() -> Self {
        tap(appIcon)
    }

    @discardableResult
    func tapDebugMenu() -> Self {
        tap(debugMenu)
    }

    @discardableResult
    func tapAcknowledgements() -> AcknowledgementsRobot {
        tap(acknowledgements)

        return AcknowledgementsRobot(app)
    }

    @discardableResult
    func tapPrivacyPolicy() -> PrivacyPolicyRobot {
        tap(privacyPolicy)

        return PrivacyPolicyRobot(app)
    }

    @discardableResult
    func tapTerms() -> TermsOfServiceRobot {
        tap(terms)

        return TermsOfServiceRobot(app)
    }
}
