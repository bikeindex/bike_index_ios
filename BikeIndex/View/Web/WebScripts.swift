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
    /// Remove top navigation that is supplanted by app navigation
    static let removeFrame: WKUserScript = {
        let source =
            """
            nav { display: none }
            .primary-footer .terms-and-stuff { display: none }
            body, .organized-left-menu { padding-top: 16px }
            .bike-overlay-wrapper { display: none }
            """
        let escapedNewlines = source.replacingOccurrences(of: "\n", with: "\\n")
        let javascript =
            """
            document.head.insertAdjacentHTML('beforeend', \"<style>\(escapedNewlines)</style>\")
            """

        Logger.webNavigation.debug("Injecting styling \(javascript, privacy: .public)")
        return WKUserScript(
            source: javascript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
    }()

    /// Remove all links _starting with_ `/membership`
    /// Remove all links _starting with_ `/donate`
    /// Remove all links equal to PayPal account link
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
