//
//  Navigator.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import OSLog
import WebKit

final class HistoryNavigator: NavigationResponder {

    // MARK: - Navigation Controller

    var canGoBack: Bool {
        wkWebView?.canGoBack ?? false
    }

    var canGoForward: Bool {
        wkWebView?.canGoForward ?? false
    }

    var historyDidChange: Bool = false

    // MARK: - Navigation Delegate

    /// Invoked when a page completes loading
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        historyDidChange = true
        child?.webView(webView, didFinish: navigation)
    }

    /// Invoked when a user taps back or forward
    override func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        historyDidChange = true
        child?.webView(webView, didCommit: navigation)
    }
}
