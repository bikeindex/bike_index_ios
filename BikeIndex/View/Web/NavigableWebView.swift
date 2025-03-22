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
/// Useful as a web view _instead of_ SFSafariViewController because we rely on hybrid web authentication
/// until a fully native UI can be completed.
/// The State variable for the `url` **must** not be modified anywhere else.
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
            navigator.wkWebView = $0
            $0.navigationDelegate = navigator
        }
        .onChange(
            of: url,
            { _, newValue in
                // When the binding changes, navigate to the new page.
                navigator.wkWebView?.load(URLRequest(url: newValue))
            }
        )
        .onChange(
            of: navigator.wkWebView?.url,
            { oldValue, newValue in
                // After a user action causes a change, update the binding.
                // This allows assigning new values to the binding to navigate to.
                if let newValue, newValue != url {
                    url = newValue
                }
            }
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
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
        url: .constant(URL("https://bikeindex.org")),
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
