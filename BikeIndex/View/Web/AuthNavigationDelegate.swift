//
//  AuthNavigationDelegate.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

/// Delegate to intercept completed OAuth callback URLs, forward them to Client, and complete authentication.
final class AuthNavigationDelegate: NavigatorChild {
    var client: Client?

    // MARK: - Decide Policy

    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        if let url = navigationAction.request.url,
            let scheme = url.scheme,
            scheme + "://" == client?.configuration.redirectUri,
            let result = await client?.accept(authCallback: url),
            result == true
        {
            return (WKNavigationActionPolicy.cancel, preferences)
        }

        return (.allow, preferences)
    }
}
