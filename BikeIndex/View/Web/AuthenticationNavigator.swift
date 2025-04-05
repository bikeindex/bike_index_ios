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
    var routeToAuthenticationPage: () -> Void

    private(set) var interceptor: Interceptor

    init(client: Client? = nil, routeToAuthenticationPage: @escaping () -> Void = {}, interceptor: Interceptor) {
        self.client = client
        self.routeToAuthenticationPage = routeToAuthenticationPage
        self.interceptor = interceptor
    }

    // MARK: - Decide Policy

    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        /// Flow: Guest > Sticker > Please Sign In
        /// Re-route the AuthSignInView experience away from /session/new.
        /// - /session/new is only for browser sessions.
        /// - APp sessions must use the ``AuthView/ViewModel/signInPageRequest`` page (or sign-in will fail!)
        /// How does the user get to /session/new? A) if they navigate around the sign-in page
        /// B) if they scan a QR code Bike Sticker
        if let signInAction = interceptor.filterSignInRedirect(navigationAction.request.url) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.routeToAuthenticationPage()
            }

            return (signInAction, preferences)
        }

        // MARK: - Stable

        /// Flow: Guest > "Sign in and get started"
        if let action = await interceptor.filterCompletedAuthentication(navigationAction.request.url,
                                                                  client: client)
        {
            return (action, preferences)
        }

        if let child {
            return await child.webView(
                webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            return (.allow, preferences)
        }
    }

    @MainActor
    struct Interceptor {
        var hostProvider: HostProvider

        var routeToAuthentication: () -> Void = {}

        /// Guest > Scan Sticker QR Code > Please Sign In
        func filterSignInRedirect(_ url: URL?) -> WKNavigationActionPolicy? {
            guard let url,
                  let prefixTrimmed = Optional(url.absoluteString.trimmingPrefix("bikeindex://")),
                  let components = URLComponents(string: String(prefixTrimmed))
            else { return nil }

            if let baseHost = hostProvider.host.host(),
               components.host != baseHost {
                /// E.g. bikeindex.org in the input URL must match bikeindex.org
                return nil
            }

            if components.path == "/session/new",
                let returnTo = components.queryItems?.first(where: { $0.name == "return_to" }),
               let decoded = returnTo.value?.removingPercentEncoding,
               decoded.contains("scanned")
             {
                return .cancel
            }

            return nil
        }

        /// Guest > Sign in and get started
        /// (aka regular authentication flow)
        func filterCompletedAuthentication(_ url: URL?, client: Client?) async -> WKNavigationActionPolicy? {
            if let url,
               let scheme = url.scheme,
               scheme + "://" == client?.configuration.redirectUri,
               let result = await client?.accept(authCallback: url),
               result == true
            {
                return WKNavigationActionPolicy.cancel
            } else {
                return nil
            }
        }
    }
}
