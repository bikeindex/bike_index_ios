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

    /// Connect WebViewKit's wrapped `WKWebView` instance to this NavigationResponder for managing updates.
    /// Required to use NavigationResponder.
    /// - Parameter wkWebView: The web view provided by `WebViewKit.WebView.init(…, viewConfig: (WKWebView) -> Void)`
    func assign(wkWebView: WKWebView?) {
        Logger.webNavigation.debug("\(#file).\(type(of: self)).\(#function) enter")
        self.wkWebView = wkWebView
        child?.assign(wkWebView: wkWebView)
    }

    // MARK: - Navigation Delegate

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction)
        async -> WKNavigationActionPolicy
    {
        Logger.webNavigation.debug("\(#file).\(type(of: self)).\(#function)-\(#line) enter")

        if let child {
            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) deferring to child navigator"
            )
            return await child.webView(webView, decidePolicyFor: navigationAction)
        } else {
            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) returning allow - no child")
            return .allow
        }
    }

    public func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        Logger.webNavigation.debug("\(#file).\(type(of: self)).\(#function)-\(#line) enter")

        if let child {
            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) deferring to child navigator"
            )
            return await child.webView(
                webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            /// memberships are not managed inside the app
            if let url = navigationAction.request.url,
                url.pathComponents.starts(with: ["/", "membership"])
                    || url.pathComponents.starts(with: ["/", "donate"])
            {
                let referralSource = AppVersionInfo().referralSource
                let donateUrl = URL(
                    string: "https://bikeindex.org/donate?referral_source=\(referralSource)")!
                Logger.webNavigation.debug("Open donate page with referral \(donateUrl)")
                await UIApplication.shared.open(donateUrl)
                Logger.webNavigation.debug(
                    "\(#file).\(type(of: self)).\(#function)-\(#line) returning cancel - donated")
                return (WKNavigationActionPolicy.cancel, preferences)
            }

            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) returning allow - no matching conditions"
            )
            return (WKNavigationActionPolicy.allow, preferences)
        }
    }

    public func webView(
        _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse
    ) async -> WKNavigationResponsePolicy {
        Logger.webNavigation.debug("\(#file).\(type(of: self)).\(#function)-\(#line) enter")

        if let child {
            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) deferring to child navigator"
            )
            return await child.webView(webView, decidePolicyFor: navigationResponse)
        } else {
            Logger.webNavigation.debug(
                "\(#file).\(type(of: self)).\(#function)-\(#line) returning allow - no child")
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
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webView(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }

    public func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        Logger.webNavigation.debug(
            "\(#file).\(type(of: self)).\(#function) with navigation=\(navigation), failed due to \(error)"
        )
        child?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webView(webView, didCommit: navigation)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webView(webView, didFinish: navigation)
    }

    public func webView(
        _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
    ) {
        Logger.webNavigation.debug(
            "\(#file).\(type(of: self)).\(#function) with navigation=\(navigation), failed due to \(error)"
        )
        child?.webView(webView, didFail: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, respondTo challenge: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?)
    {
        Logger.webNavigation.debug("\(#file).\(#function) enter")

        if let child {
            return await child.webView(webView, respondTo: challenge)
        } else {
            Logger.webNavigation.debug(
                "\(#file).\(#function) returning performDefaultHandling - no child"
            )
            return (.performDefaultHandling, nil)
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webViewWebContentProcessDidTerminate(webView)
    }

    public func webView(
        _ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge,
        shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void
    ) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")

        if let child {
            return child.webView(
                webView, authenticationChallenge: challenge,
                shouldAllowDeprecatedTLS: decisionHandler)
        } else {
            decisionHandler(false)
            Logger.webNavigation.debug(
                "\(#file).\(#function) returning reject - no child"
            )
        }
    }

    public func webView(
        _ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload
    ) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webView(webView, navigationAction: navigationAction, didBecome: download)
    }

    public func webView(
        _ webView: WKWebView, navigationResponse: WKNavigationResponse,
        didBecome download: WKDownload
    ) {
        Logger.webNavigation.debug("\(#file).\(#function) enter")
        child?.webView(webView, navigationResponse: navigationResponse, didBecome: download)
    }
}
