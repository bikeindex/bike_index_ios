//
//  AuthNavigationDelegate.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

@Observable
/// Delegate to intercept completed OAuth callback URLs, forward them to Client, and complete authentication.
final class AuthenticationNavigator: NavigationResponder {
    @ObservationIgnored
    /// Allow composition for ``AuthView/ViewModel`` to connect this client.
    /// Authentication cannot proceed until this value is assigned.
    var client: Client?

    @ObservationIgnored
    var routeToAuthenticationPage: () -> Void = {}

    // MARK: - Decide Policy

    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        // TODO: Consolidate these two if-statements

        if let url = navigationAction.request.url {
            let firstHalf = url.absoluteString.split(separator: "?")[0]
            if firstHalf == "https://bikeindex.org/session/new" {
                print(
                    "Alright, so this request has to be picked out and directed to `routeToAuthenticationPage`"
                )
            }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        }

        /// Re-route the AuthSignInView experience away from /session/new.
        /// - /session/new is only for browser sessions.
        /// - APp sessions must use the ``AuthView/ViewModel/signInPageRequest`` page (or sign-in will fail!)
        /// How does the user get to /session/new? A) if they navigate around the sign-in page
        /// B) if they scan a QR code Bike Sticker
        if let url = navigationAction.request.url,
            url.absoluteString
                == "https://bikeindex.org/session/new?return_to=%2Fbikes%2FA40340%2Fscanned%3Forganization_id%3D2167"
        {
            //            return (.allow, preferences)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                // TODO: Move this out of asyncAfter and into a different delegate function that occurs _after_ this decision, or elsewhere
                self?.routeToAuthenticationPage()
            }

            return (.cancel, preferences)
        }

        // MARK: - Stable

        if let url = navigationAction.request.url,
            let scheme = url.scheme,
            scheme + "://" == client?.configuration.redirectUri,
            let result = await client?.accept(authCallback: url),
            result == true
        {
            return (WKNavigationActionPolicy.cancel, preferences)
        }

        if let child {
            return await child.webView(
                webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            return (.allow, preferences)
        }
    }
}
