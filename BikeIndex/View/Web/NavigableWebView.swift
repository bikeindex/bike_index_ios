//
//  NavigableWebView.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import SwiftUI
import WebKit
import WebViewKit

struct NavigableWebView: View {
    @Environment(Client.self) var client

    var url: URL?

    @State var navigator = Navigator()

    var body: some View {
        WebView(url: url,
                configuration: client.webConfiguration) {
            navigator.wkWebView = $0
            $0.navigationDelegate = navigator
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Back", systemImage: "chevron.backward") {
                    navigator.wkWebView?.goBack()
                }
                .disabled(!navigator.canGoBack)
                .onChange(of: navigator.historyDidChange) { oldValue, newValue in
                    navigator.historyDidChange = false
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Forward", systemImage: "chevron.forward") {
                    navigator.wkWebView?.goForward()
                }
                .disabled(!navigator.canGoForward)
                .onChange(of: navigator.historyDidChange) { oldValue, newValue in
                    navigator.historyDidChange = false
                }
            }
        }
    }
}

@Observable class Navigator: NSObject, WKNavigationDelegate {

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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        historyDidChange = true
    }
}
