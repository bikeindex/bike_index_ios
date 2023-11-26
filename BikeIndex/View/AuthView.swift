//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import UIKit
import SwiftUI
import AuthenticationServices
import WebKit

fileprivate extension ClientConfiguration {
    var authorizeUrl: URL {
        var url = host.appending(path: "oauth/authorize")

        let queryItems: [URLQueryItem] = [
            ("client_id", clientId),
            ("response_type", "code"),
            ("redirect_uri", redirectUri),
            ("scope", oauthScopes.queryItem)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
        url.append(queryItems: queryItems)
        return url
    }
}

struct AuthView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    /// api client for performing auth
    @Environment(Client.self) var client

    var body: some View {
        NavigationStack {
            Button("Sign In") {
                Task {
                    let urlWithToken = try await webAuthenticationSession.authenticate(
                        using: client.configuration.authorizeUrl,
                        callbackURLScheme: client.configuration.redirectUri,
                        preferredBrowserSession: .shared)
                    await client.accept(authCallback: urlWithToken)
                }
            }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            #endif
            .navigationTitle("Please sign in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
