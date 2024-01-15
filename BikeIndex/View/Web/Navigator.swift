//
//  Navigator.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import WebKit
import OSLog

@Observable class Navigator: NavigatorChild {

    // MARK: - Navigation Controller

    var wkWebView: WKWebView?

    var canGoBack: Bool {
        wkWebView?.canGoBack ?? false
    }

    var canGoForward: Bool {
        wkWebView?.canGoForward ?? false
    }

    var historyDidChange: Bool = false

    // MARK: - Navigation Delegate

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        historyDidChange = true
        child?.webView(webView, didFinish: navigation)
    }
}

