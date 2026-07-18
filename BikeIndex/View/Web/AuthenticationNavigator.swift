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
/// Must be annotated Observable for parent class conformance.
final class AuthenticationNavigator: NavigationResponder {
    /// Allow ``AuthView/ViewModel`` to connect this client at runtime.
    /// Authentication cannot proceed until this value is assigned.
    @ObservationIgnored var client: Client?
    @ObservationIgnored
    let signInPageRequest: URLRequest
    @ObservationIgnored
    private(set) var interceptor: Interceptor

    init(
        clientConfiguration: ClientConfiguration
    ) {
        self.signInPageRequest = clientConfiguration.signInPageRequest
        self.interceptor = Interceptor(hostProvider: clientConfiguration.hostProvider)
    }

    private func routeToAuthenticationPage() {
        assert(self.wkWebView != nil)
        self.wkWebView?.load(signInPageRequest)
    }

    // MARK: - Decide Policy

    /// Pre-condition: self.client is not nil
    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        Logger.auth.debug("\(#file).\(#function) enter")
        assert(client != nil)

        /// Flow: Guest > Sticker > Please Sign In
        /// Re-route the AuthSignInView experience away from /session/new.
        /// - /session/new is only for browser sessions.
        /// - APp sessions must use the ``AuthView/ViewModel/signInPageRequest`` page (or sign-in will fail!)
        /// How does the user get to /session/new?
        /// A) if they navigate around the sign-in page (ex: help -> sign in)
        /// B) if they scan a QR code Bike Sticker (universal link)
        if let signInAction = interceptor.filterSignInRedirect(navigationAction.request.url) {
            routeToAuthenticationPage()

            Logger.auth.debug(
                "\(#file).\(#function) found a sign-in redirect, routing to authentication page")
            return (signInAction, preferences)
        }

        // MARK: - Stable

        /// Flow: Guest > "Sign in and get started"
        if let action = await interceptor.filterCompletedAuthentication(
            navigationAction.request.url,
            client: client)
        {
            Logger.auth.debug(
                "\(#file).\(#function) interceptor successfully completed authentication")
            return (action, preferences)
        }

        if let child {
            let result = await child.webView(
                webView, decidePolicyFor: navigationAction, preferences: preferences)
            Logger.auth.debug("\(#file).\(#function) deferring decision via child navigator")
            return result
        } else {
            Logger.auth.debug(
                "\(#file).\(#function) fallback: returning allow for \(String(describing: navigationAction.request.url))"
            )
            return (.allow, preferences)
        }
    }

    @MainActor
    struct Interceptor {
        var hostProvider: HostProvider

        /// Guest > Scan Sticker QR Code > Please Sign In
        func filterSignInRedirect(_ url: URL?) -> WKNavigationActionPolicy? {
            Logger.auth.debug(
                "\(#file).\(#function) Enter, checking \(String(describing: url)) against session/new"
            )

            guard let url,
                let prefixTrimmed = Optional(url.absoluteString.trimmingPrefix("bikeindex://")),
                let components = URLComponents(string: String(prefixTrimmed))
            else {
                Logger.auth.debug(
                    "\(#file).\(#function) returning nil - invalid url or components of \(String(describing: url), privacy: .auto)"
                )
                return nil
            }

            if let baseHost = hostProvider.host.host(),
                components.host != baseHost
            {
                /// E.g. bikeindex.org in the input URL must match bikeindex.org
                Logger.auth.debug(
                    "\(#file).\(#function) exiting, host mismatch, \(baseHost) vs. \(String(describing: components.host))"
                )
                return nil
            }

            /// Ex: `session/new?return_to=SAM000000`
            if components.path == "/session/new",
                let returnTo = components.queryItems?.first(where: { $0.name == "return_to" }),
                let decoded = returnTo.value?.removingPercentEncoding,
                decoded.contains("scanned")
            {
                Logger.auth.debug(
                    "\(#file).\(#function) returning cancel for session/new with scanned return_to")
                return .cancel
            }

            Logger.auth.debug(
                "\(#file).\(#function) returning nil - no matching condition against \(url)")
            return nil
        }

        /// Guest > Sign in and get started
        /// (aka regular authentication flow)
        func filterCompletedAuthentication(_ url: URL?, client: Client?) async
            -> WKNavigationActionPolicy?
        {
            Logger.auth.debug("\(#file).\(#function) enter")

            if let url,
                let scheme = url.scheme,
                scheme + "://" == client?.configuration.redirectUri,
                let result = await client?.accept(authCallback: url),
                result == true
            {
                Logger.auth.debug(
                    "\(#file) \(#function) returning cancel - authentication completed")
                return WKNavigationActionPolicy.cancel
            } else {
                Logger.auth.debug(
                    "\(#file).\(#function) returning nil - authentication not completed against \(String(describing: url))"
                )
                return nil
            }
        }
    }
}
