//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import WebKit
import WebViewKit
import OSLog

fileprivate extension ClientConfiguration {
    var authorizeQueryItems: [URLQueryItem] {
        return [
            ("client_id", clientId),
            ("response_type", "code"),
            ("redirect_uri", redirectUri),
            ("scope", oauthScopes.queryItem)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
    }
}

class AuthNavigationDelegate: NSObject, WKNavigationDelegate {
    var client: Client?

    // MARK: - Act on navigation

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Logger.auth.info("\(#function) with \(navigation.description)")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.auth.info("\(#function) with \(navigation.description)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.auth.info("\(#function) with \(navigation.description)")
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        Logger.auth.info("\(#function) with \(navigation.description)")
    }

    // MARK: - Decide Policy

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        Logger.auth.info("\(#function) with \(navigationAction)")
        return .allow
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        Logger.auth.info("\(#function) with \(navigationAction), and preferences \(preferences)")

        if let url = navigationAction.request.url,
           let result = await client?.accept(authCallback: url),
           result {
            return (WKNavigationActionPolicy.cancel, preferences)
        }

        return (.allow, preferences)
    }
}

/// NOTE: Network traffic for ASWebAuthenticationSession will run in the WebKitNetworking process!
/// This means that Proxyman will not show app authentication in the "Bike Index" app. You will have to look for the
/// host or across all networking in Proxyman!
struct AuthView: View {
    /// api client for performing auth
    @Environment(Client.self) var client

    @State private var displaySignIn = false
    private var authNavigationDelegate = AuthNavigationDelegate()

    var body: some View {
        NavigationStack {
            WelcomeView()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        displaySignIn = true
                    } label: {
                        Label("Sign in and get started", systemImage: "person.crop.circle.dashed")
                            .font(.title3)
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
#if DEBUG
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
#endif
            }
            .sheet(isPresented: $displaySignIn, content: {
                WebView(url: oAuthUrl, webConfiguration: client.webConfiguration) {
                    authNavigationDelegate.client = client
                    $0.navigationDelegate = authNavigationDelegate
                }
            })

            .navigationTitle("Welcome to Bike Index")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var oAuthUrl: URL? {
        OAuth.authorize(queryItems: client.configuration.authorizeQueryItems).request(for: client.api.configuration).url
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
