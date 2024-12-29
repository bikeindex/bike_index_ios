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

/// NOTE: Network traffic for ASWebAuthenticationSession will run in the WebKitNetworking process!
/// This means that Proxyman will not show app authentication in the "Bike Index" app. You will have to look for the
/// host or across all networking in Proxyman!
struct AuthView: View {
    /// API client for performing auth
    @Environment(Client.self) var client
    @Environment(\.dismiss) var dismiss

    @State private var displaySignIn = false
    /// Object to intercept authentication events from the sign-in webview and forward them to Client
    private var authNavigationDelegate = AuthNavigationDelegate()

    @State private var path = NavigationPath()
    @State private var showDebugMenu = false

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView().toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        displaySignIn = true
                    } label: {
                        Label("Sign in and get started", systemImage: "person.crop.circle.dashed")
                            .accessibilityIdentifier("SignIn")
                            .font(.title3)
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.borderedProminent)
                }

#if DEBUG
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: Nav.debugSettings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
#endif
            }
            .sheet(isPresented: $displaySignIn, content: {
                NavigationStack {
                    NavigableWebView(url: .constant(oAuthUrl!),
                                     navigator: HistoryNavigator(child: authNavigationDelegate))
                    .environment(client)
                    .navigationTitle("Sign in")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                }
            })
            .navigationTitle("Welcome to Bike Index")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Nav.self) { navSelection in
                switch navSelection {
                case .debugSettings:
                    SettingsView(path: $path)
                        .accessibilityIdentifier("Settings")
                }
            }
        }
        .onAppear {
            authNavigationDelegate.client = client
        }
    }

    private var oAuthUrl: URL? {
        OAuth.authorize(queryItems: client.configuration.authorizeQueryItems).request(for: client.api.configuration).url
    }

    enum Nav: Identifiable {
        var id: Self { self }

        case debugSettings
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
