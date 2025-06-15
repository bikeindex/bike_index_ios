//
//  BikeIndexLink.swift
//  BikeIndex
//
//  Created by Jack on 6/15/25.
//

import OSLog
import SwiftUI

enum BikeIndexLink: Identifiable {
    // MARK: General
    case oauthApplications
    case serials
    case stolenBikeWhatToDo
    case stolenBikeFAQ
    case howToUseStickers

    // MARK: Policies
    case privacyPolicy
    case termsOfService
    case help

    // MARK: Account
    case accountUserSettings
    case accountPassword
    case accountSharingPersonalPage
    case accountRegistrationOrganization
    case deleteAccount

    var id: Self { self }

    /// Return a displayable link within attributed text for inline display
    func on(_ base: URL) -> AttributedString {
        let markdownSource: String
        switch self {
        case .oauthApplications:
            markdownSource = "[Edit your OAuth Applications at bikeindex.org](\(link(base: base)))"
        case .serials:
            markdownSource =
                "Every bike has a unique serial number, it's how they are identified. To learn more or see some examples, [go to our serial page](\(link(base: base)))."
        case .stolenBikeFAQ:
            markdownSource =
                "Learn more about [How to get your stolen bike back](\(link(base: base)))"
        case .help, .privacyPolicy, .termsOfService, .deleteAccount, .accountUserSettings,
            .accountPassword, .accountSharingPersonalPage, .accountRegistrationOrganization,
            .stolenBikeWhatToDo, .howToUseStickers:
            return AttributedString()
        }

        do {
            return try AttributedString(markdown: markdownSource)
        } catch {
            Logger.views.error(
                "Failed to create link from \(self.path, privacy: .public) on base \(base, privacy: .public)"
            )
            return AttributedString(stringLiteral: "Internal error creating link.")
        }
    }

    /// Return a plain URL for an action on another display (non-textual button)
    func link(base: URL) -> URL {
        base.appending(path: path)
    }

    var path: String {
        switch self {
        case .oauthApplications:
            // https://bikeindex.org/oauth/applications
            return "oauth/applications"
        case .serials:
            // https://bikeindex.org/serials
            return "serials"
        case .stolenBikeWhatToDo:
            // https://bikeindex.org/stolen
            return "stolen"
        case .stolenBikeFAQ:
            // https://bikeindex.org/info/how-to-get-your-stolen-bike-back
            return "info/how-to-get-your-stolen-bike-back"
        case .howToUseStickers:
            // https://bikeindex.org/info/how-to-use-bike-index-qr-stickers
            return "info/how-to-use-bike-index-qr-stickers"

        case .privacyPolicy:
            // https://bikeindex.org/privacy
            return "privacy"
        case .termsOfService:
            // https://bikeindex.org/terms
            return "terms"
        case .help:
            // https://bikeindex.org/help
            return "help"

        case .accountUserSettings:
            // https://bikeindex.org/my_account/edit
            return "my_account/edit"
        case .accountPassword:
            // https://bikeindex.org/my_account/edit/password
            return "my_account/edit/password"
        case .accountSharingPersonalPage:
            // https://bikeindex.org/my_account/edit/sharing
            return "my_account/edit/sharing"
        case .accountRegistrationOrganization:
            // https://bikeindex.org/my_account/edit/registration_organizations
            return "my_account/edit/registration_organizations"
        case .deleteAccount:
            // https://bikeindex.org/my_account/edit/delete_account
            return "my_account/edit/delete_account"
        }
    }
}
