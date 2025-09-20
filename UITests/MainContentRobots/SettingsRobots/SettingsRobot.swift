//
//  SettingsRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

/// Robot for testing the settings page.
final class SettingsRobot: Robot {
    lazy var appIcon = app.buttons["App Icon"]

    /// Manage Account
    lazy var userSettings = app.buttons["User Settings"]
    lazy var password = app.buttons["Password"]
    lazy var sharingAndPersonalPage = app.buttons["Sharing + Personal Page"]
    lazy var registrationOrganization = app.buttons["Registration Organization"]

    /// Developer
    lazy var debugMenu = app.buttons["Debug menu"]

    /// About
    lazy var acknowledgements = app.buttons["Acknowledgements"]
    lazy var privacyPolicy = app.buttons["Privacy Policy"]
    lazy var terms = app.buttons["Terms of Service"]

    @discardableResult
    func tapAppIcon() -> Self {
        tap(appIcon)
    }

    @discardableResult
    func tapUserSettings() -> Self {
        tap(userSettings)
    }

    @discardableResult
    func tapPassword() -> Self {
        tap(password)
    }

    @discardableResult
    func tapSharingAndPersonalPage() -> Self {
        tap(sharingAndPersonalPage)
    }

    @discardableResult
    func tapRegistrationOrganization() -> Self {
        tap(registrationOrganization)
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

    @discardableResult
    func checkTextExists(_ text: String) -> Self {
        assert(app.staticTexts[text], [.exists])
    }
}
