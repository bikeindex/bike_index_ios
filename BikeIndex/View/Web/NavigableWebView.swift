//
//  NavigableWebView.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import SwiftUI
import WebKit
import WebViewKit

/// Display an inline URL with backward/forward page controls.
/// Useful as a web view _instead of_ SFSafariViewController
/// because we rely on hybrid web authentication
/// until a fully native UI can be completed.
struct NavigableWebView: View {
    @Environment(Client.self) var client

    @Binding private var url: URL
    private var navigator: HistoryNavigator

    init(url: Binding<URL>, navigator: HistoryNavigator = HistoryNavigator()) {
        self._url = url
        self.navigator = navigator
    }

    init(constantLink: BikeIndexLink, host: URL) {
        self._url = Binding.constant(constantLink.link(base: host))
        self.navigator = HistoryNavigator()
    }

    var body: some View {
        WebView(
            url: url,
            configuration: client.webConfiguration
        ) {
            #if !RELEASE
            $0.isInspectable = true
            #endif
            navigator.assign(wkWebView: $0)
            $0.navigationDelegate = navigator
            $0.allowsLinkPreview = false
        }
        .onChange(
            of: url,
            { _, newValue in
                // Accept updates from the owning State/Binding, navigate to the new page.
                navigator.wkWebView?.load(URLRequest(url: newValue))
            }
        )
        .onChange(
            of: navigator.wkWebView?.url,
            { oldValue, newValue in
                // Accept updates from the webView (such as clicking links).
                // After a user action causes a change, update the binding.
                // This allows assigning new values to the binding to navigate to.
                if let newValue, newValue != url {
                    url = newValue
                }
            }
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if navigator.isLoading {
                    ProgressView()
                }
                Group {
                    Button("Back", systemImage: "chevron.backward") {
                        navigator.wkWebView?.goBack()
                    }
                    .accessibilityIdentifier(Identifiers.backButton.rawValue)
                    .disabled(!navigator.canGoBack)

                    Button("Forward", systemImage: "chevron.forward") {
                        navigator.wkWebView?.goForward()
                    }
                    .accessibilityIdentifier(Identifiers.forwardButton.rawValue)
                    .disabled(!navigator.canGoForward)
                }
                .onChange(of: navigator.historyDidChange) { _, _ in
                    navigator.historyDidChange = false
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigableWebView(
        url: .constant(URL(string: "https://bikeindex.org")!),
        navigator: HistoryNavigator()
    )
    .environment(try! Client())
}

extension NavigableWebView {
    enum Identifiers: String {
        case backButton = "WebViewBack"
        case forwardButton = "WebViewForward"
    }
}
