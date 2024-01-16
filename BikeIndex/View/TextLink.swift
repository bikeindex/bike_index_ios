//
//  TextLink.swift
//  BikeIndex
//
//  Created by Jack on 11/23/23.
//

import SwiftUI
import OSLog

enum BikeIndexLink: Identifiable {
    case oauthApplications
    case serials
    case stolenBikeFAQ
    case privacyPolicy
    case termsOfService

    var id: Self { self }

    /// Return a displayable link within normal text
    func on(_ base: URL) -> AttributedString {
        let markdownSource: String
        switch self {
        case .oauthApplications:
            markdownSource = "[Edit your OAuth Applications at bikeindex.org](\(base.appending(path: link)))"
        case .serials:
            markdownSource = "Every bike has a unique serial number, it's how they are identified. To learn more or see some examples, [go to our serial page](\(base.appending(path: link)))."
        case .stolenBikeFAQ:
            markdownSource = "Learn more about [How to get your stolen bike back](\(base.appending(path: link)))"
        case .privacyPolicy, .termsOfService:
            return AttributedString()
        }

        do {
            return try AttributedString(markdown: markdownSource)
        } catch {
            Logger.views.error("Failed to create link from \(self.link, privacy: .public) on base \(base, privacy: .public)")
            return AttributedString(stringLiteral: "Internal error creating link.")
        }
    }

    func link(base: URL) -> URL {
        base.appending(path: self.link)
    }

    var link: String {
        switch self {
        case .oauthApplications:
            // https://bikeindex.org/oauth/applications
            return "oauth/applications"
        case .serials:
            // https://bikeindex.org/serials
            return "serials"
        case .stolenBikeFAQ:
            // https://bikeindex.org/info/how-to-get-your-stolen-bike-back
            return "info/how-to-get-your-stolen-bike-back"
        case .privacyPolicy:
            // https://bikeindex.org/privacy
            return "privacy"
        case .termsOfService:
            // https://bikeindex.org/terms
            return "terms"
        }
    }
}

/// Display constant and clickable Markdown links for Production
/// Display dyanmic and non-clickable Markdown links for Development
///
/// Why does this exist??
/// `Text` does **not** support `URL`s. You must provide a constant _string_.
struct TextLink: View {
    var base: URL
    var link: BikeIndexLink

    var body: some View {
        Text(link.on(base))
    }
}

#Preview {
    let localhost = URL(string: "http://localhost").unsafelyUnwrapped
    return VStack {
        ForEach([BikeIndexLink.oauthApplications, .serials, .stolenBikeFAQ]) { item in
            TextLink(base: localhost, link: item)
                .padding()
            Spacer()
        }
    }
}
