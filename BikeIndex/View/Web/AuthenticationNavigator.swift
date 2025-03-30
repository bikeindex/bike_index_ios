//
//  AuthNavigationDelegate.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

/// Delegate to intercept completed OAuth callback URLs, forward them to Client, and complete authentication.
final class AuthenticationNavigator: NavigationResponder {
    /// Allow composition for ``AuthView/ViewModel`` to connect this client.
    /// Authentication cannot proceed until this value is assigned.
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

        if let child {
            return await child.webView(webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            return (.allow, preferences)
        }
    }
}
