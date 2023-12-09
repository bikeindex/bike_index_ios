//
//  TextLink.swift
//  BikeIndex
//
//  Created by Jack on 11/23/23.
//

import SwiftUI
import OSLog

enum BikeIndexLink: CustomDebugStringConvertible {
    case oauthApplications
    case serials

    func on(_ base: URL) -> AttributedString {
        let markdownSource: String
        switch self {
        case .oauthApplications:
            markdownSource = "[Edit your OAuth Applications at bikeindex.org](\(base.appending(path: "oauth/applications")))"
        case .serials:
            markdownSource = "Every bike has a unique serial number, it's how they are identified. To learn more or see some examples, [go to our serial page](\(base.appending(path: "serials")))."
        }

        do {
            return try AttributedString(markdown: markdownSource)
        } catch {
            Logger.views.error("Failed to create link from \(self.debugDescription, privacy: .public) on base \(base, privacy: .public)")
            return AttributedString(stringLiteral: "Internal error creating link.")
        }
    }

    var debugDescription: String {
        switch self {
        case .oauthApplications:
            return "oauth/applications"
        case .serials:
            return "serials"
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
        Spacer()
        TextLink(base: localhost, link: .oauthApplications)
            .padding()
        Divider()
        TextLink(base: localhost, link: .serials)
            .padding()
        Spacer()
    }
}
