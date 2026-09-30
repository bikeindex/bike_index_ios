//
//  WebScripts.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

@MainActor
/// JavaScript injection
struct WebScripts {
    /// Styling applied to every user: hides chrome the app supplants (footer terms,
    /// overlays, banners) and adjusts padding. Does NOT touch `nav` — see `hideNav`.
    static let removeFrame: WKUserScript = {
        let css =
            """
            .primary-footer .terms-and-stuff { display: none }
            body, .organized-left-menu { padding-top: 16px }
            .bike-overlay-wrapper { display: none }
            div.card.organized-access-panel { display: none }
            .credibility-score, .parking-notifications-wrap { display: none }
            #review-app-banner { display: none }
            """
        return makeStyleScript(css)
    }()

    /// Hides the top `nav` element, which is supplanted by app navigation for
    /// non-org users. Org users need `nav` visible to render their per-organization
    /// menu, so this script is registered only when `userIsInOrganization == false`.
    static let hideNav: WKUserScript = {
        makeStyleScript("nav { display: none }")
    }()

    private static func makeStyleScript(_ css: String) -> WKUserScript {
        let escaped = css.replacingOccurrences(of: "\n", with: "\\n")
        let javascript =
            "document.head.insertAdjacentHTML('beforeend', \"<style>\(escaped)</style>\")"
        Logger.webNavigation.debug("Injecting styling \(javascript, privacy: .public)")
        return WKUserScript(
            source: javascript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
    }

    /// Remove all links _starting with_ `/membership`
    /// Remove all links _starting with_ `/donate`
    /// Remove all links equal to PayPal account link
    /// Applies to US App store users _only_: https://developer.apple.com/news/?id=9txfddzf
    static let hideMembership: WKUserScript = {
        let source =
            """
            document.querySelectorAll('a[href^="/membership"]').forEach(el => el.remove());
            document.querySelectorAll('a[href^="/donate"]').forEach(el => el.remove());
            document.querySelectorAll('a[href="https://www.paypal.me/bikeindex"]').forEach(el => el.remove());
            """

        Logger.webNavigation.debug("Injecting href manipulation \(source, privacy: .public)")
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
    }()
}
