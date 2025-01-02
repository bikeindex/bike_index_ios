//
//  NavigatorChild.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

@preconcurrency import WebKit // TODO: Upgrade WebKit for Swift 6 concurrency
import OSLog

open class NavigatorChild: NSObject, WKNavigationDelegate {
    var child: NavigatorChild?

    init(child: NavigatorChild? = nil) {
        self.child = child
        if child != nil {
            Logger.views.debug("Created Navigator instance with child \(child, privacy: .public)")
        }
    }

    // MARK: - Navigation Delegate

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let child {
            return await child.webView(webView, decidePolicyFor: navigationAction)
        } else {
            return .allow
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        if let child {
            return await child.webView(webView, decidePolicyFor: navigationAction, preferences: preferences)
        } else {
            return (WKNavigationActionPolicy.allow, preferences)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        if let child {
            return await child.webView(webView, decidePolicyFor: navigationResponse)
        } else {
            return .allow
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        child?.webView(webView, didStartProvisionalNavigation: navigation)
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        child?.webView(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        child?.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        child?.webView(webView, didCommit: navigation)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        child?.webView(webView, didFinish: navigation)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        child?.webView(webView, didFail: navigation, withError: error)
    }

    public func webView(_ webView: WKWebView, respondTo challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let child {
            return await child.webView(webView, respondTo: challenge)
        } else {
            return (.performDefaultHandling, nil)
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        child?.webViewWebContentProcessDidTerminate(webView)
    }

    public func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        if let child {
            return child.webView(webView, authenticationChallenge: challenge, shouldAllowDeprecatedTLS: decisionHandler)
        } else {
            decisionHandler(false)
        }
    }

    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        child?.webView(webView, navigationAction: navigationAction, didBecome: download)
    }

    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        child?.webView(webView, navigationResponse: navigationResponse, didBecome: download)
    }
}
