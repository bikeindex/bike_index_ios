//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftUI
import WebKit
import WebViewKit

extension ClientConfiguration {
    fileprivate var authorizeQueryItems: [URLQueryItem] {
        return [
            ("client_id", clientId),
            ("response_type", "code"),
            ("redirect_uri", redirectUri),
            ("scope", oauthScopes.queryItem),
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
    }
}

/// NOTE: Network traffic for ASWebAuthenticationSession will run in the WebKitNetworking process!
/// This means that Proxyman will not show app authentication in the "Bike Index" app. You will have to look for the
/// host or across all networking in Proxyman!
/// Entry-point for all users to sign-in.
struct AuthView: View {
    /// API client for performing auth
    @Environment(Client.self) var client
    /// ViewModel to manage state.
    /// `viewModel.authNavigator.client` must be connected at runtime.
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.topLevelPath) {
            WelcomeView()
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            viewModel.displaySignIn = true
                        } label: {
                            Label(
                                "Sign in and get started",
                                systemImage: "person.crop.circle.dashed"
                            )
                            .accessibilityIdentifier("SignIn")
                            .font(.title3)
                            .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    ToolbarItemGroup(placement: .topBarLeading) {
                        #if DEBUG
                        NavigationLink(value: ViewModel.Nav.debugSettings) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        #endif
                        NavigationLink(value: ViewModel.Nav.help) {
                            Label("Help", systemImage: "book.closed")
                        }
                    }
                }
                .navigationTitle("Welcome to Bike Index")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ViewModel.Nav.self) { navSelection in
                    switch navSelection {
                    case .debugSettings:
                        SettingsPage(path: $viewModel.topLevelPath)
                            .environment(client)
                            .accessibilityIdentifier("Settings")
                    case .help:
                        NavigableWebView(constantLink: .help, host: client.configuration.host)
                            .environment(client)
                            .navigationTitle("Help")
                    }
                }
        }
        .sheet(isPresented: $viewModel.displaySignIn) {
            NavigationStack {
                NavigableWebView(
                    url: .constant(oAuthUrl!),
                    navigator: HistoryNavigator(child: viewModel.authNavigator)
                )
                .environment(client)
                .navigationTitle("Sign in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            viewModel.displaySignIn = false
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.authNavigator.client = client
        }
    }

    /// URL helper to find the right user-facing authorization page for this app config.
    private var oAuthUrl: URL? {
        OAuth.authorize(queryItems: client.configuration.authorizeQueryItems).request(
            for: client.api.configuration
        ).url
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
