//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import AuthenticationServices
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
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    /// api client for performing auth
    @Environment(Client.self) var client

    var body: some View {
        NavigationStack {
            WelcomeView()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        Task {
                            guard let authorizeUrl = OAuth.authorize(queryItems: client.configuration.authorizeQueryItems).request(for: client.api.configuration).url else {
                                Logger.api.debug("Failed to construct authorization request")
                                return
                            }
                            let redirectUri = client.configuration.redirectUri.trimmingCharacters(in: .alphanumerics.inverted)
                            let urlWithToken = try await webAuthenticationSession.authenticate(
                                using: authorizeUrl,
                                callbackURLScheme: redirectUri,
                                preferredBrowserSession: .shared)
                            await client.accept(authCallback: urlWithToken)
                        }
                    }, label: {
                        Label("Sign in and get started", systemImage: "person.crop.circle.dashed")
                            .font(.title3)
                            .labelStyle(.titleAndIcon)
                    })
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
            .navigationTitle("Welcome to Bike Index")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
