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

    var routeToAuthenticationPage: () -> Void = { }

    // MARK: - Decide Policy

    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        if let url = navigationAction.request.url,
           url.absoluteString == "https://bikeindex.org/session/new?return_to=%2Fbikes%2FA40340%2Fscanned%3Forganization_id%3D2167" {
            print("ALRIGHT HERE WE FOUND THE NAVIGATION ACTION THAT NEEDS TO REDIRECT INTO CLIENT-INJECTED PARAMS")
//            return (.allow, preferences)

            routeToAuthenticationPage()

            return (.cancel, preferences)
        }


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
