//
//  NavigationResponder.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

@Observable
open class NavigationResponder: NSObject, WKNavigationDelegate {
    var child: NavigationResponder?

    var wkWebView: WKWebView?

    init(child: NavigationResponder? = nil) {
        self.child = child
        if child != nil {
            Logger.views.debug("Created Navigator instance with child \(child, privacy: .public)")
        }
    }

    func assign(wkWebView: WKWebView?) {
        self.wkWebView = wkWebView
        child?.assign(wkWebView: wkWebView)
    }

    // MARK: - Navigation Delegate

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction)
        async -> WKNavigationActionPolicy
    {
        if let child {
            return await child.webView(webView, decidePolicyFor: navigationAction)
        } else {
            return .allow
        }
    }

    public func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        if let child {
            return await child.webView(
                webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            /// memberships are not managed inside the app
            if let url = navigationAction.request.url,
                url.pathComponents.starts(with: ["/", "membership"])
                    || url.pathComponents.starts(with: ["/", "donate"])
            {
                Logger.webNavigation.debug("Redirect from membership to donate")
                let donateUrl = URL(stringLiteral: "https://bikeindex.org/donate")
                await UIApplication.shared.open(donateUrl)
                return (WKNavigationActionPolicy.cancel, preferences)
            }

            return (WKNavigationActionPolicy.allow, preferences)
        }
    }

    public func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse
    ) async -> WKNavigationResponsePolicy {
        if let child {
            return await child.webView(webView, decidePolicyFor: navigationResponse)
        } else {
            return .allow
        }
    }

    public func webView(
        _ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        child?.webView(webView, didStartProvisionalNavigation: navigation)
    }

    public func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        child?.webView(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }

    public func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        child?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        child?.webView(webView, didCommit: navigation)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        child?.webView(webView, didFinish: navigation)
    }

    public func webView(
        _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
    ) {
        child?.webView(webView, didFail: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, respondTo challenge: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        if let child {
            return await child.webView(webView, respondTo: challenge)
        } else {
            return (.performDefaultHandling, nil)
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        child?.webViewWebContentProcessDidTerminate(webView)
    }

    public func webView(
        _ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge,
        shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void
    ) {
        if let child {
            return child.webView(
                webView, authenticationChallenge: challenge,
                shouldAllowDeprecatedTLS: decisionHandler)
        } else {
            decisionHandler(false)
        }
    }

    public func webView(
        _ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload
    ) {
        child?.webView(webView, navigationAction: navigationAction, didBecome: download)
    }

    public func webView(
        _ webView: WKWebView, navigationResponse: WKNavigationResponse,
        didBecome download: WKDownload
    ) {
        child?.webView(webView, navigationResponse: navigationResponse, didBecome: download)
    }
}
