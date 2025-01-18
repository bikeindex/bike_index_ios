//
//  DebugMenu.swift
//  BikeIndex
//
//  Created by Jack on 1/6/24.
//

import SwiftUI
import WebViewKit

#if DEBUG
struct DebugMenu: View {
    @Environment(Client.self) var client

    @State var secretHidden = true
    @State var showOAuthApplicationsPage = false

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }

    var body: some View {
        Form {
            if let expirationDate = client.auth?.expiration
            {
                Section {
                    Text("OAuth Token expires at: \(DebugMenu.dateFormatter.string(from: expirationDate))")
                } header: {
                    Text("Session")
                }
            }

            Section {
                Text("Host:\n`\(client.configuration.host.description)`")
                Text("Port:\n`\(String(client.configuration.port))`")
            } header: {
                Text("Endpoint")
            }

            Section {
                Text("Client ID:\n`\(client.configuration.clientId)`")
                Group {
                    if secretHidden {
                        Text("Tap to reveal/hide client secret")
                    } else {
                        Text("Secret:\n`\(client.configuration.secret)`")
                    }
                }.onTapGesture {
                    secretHidden.toggle()
                }
                Text("Redirect:\n`\(client.configuration.redirectUri)`")
                List(client.configuration.oauthScopes) { scope in
                    HStack {
                        Toggle("`\(scope.rawValue)`", isOn: .constant(true))
                            .disabled(true)
                            .toggleStyle(.switch)
                    }
                }
            } header: {
                Text("OAuth")
            } footer: {
                TextLink(base: client.configuration.host, link: .oauthApplications)
                    .environment(\.openURL, OpenURLAction(handler: { url in
                        showOAuthApplicationsPage = true
                        return .handled
                    }))
            }
        }
        .navigationDestination(isPresented: $showOAuthApplicationsPage) {
            NavigableWebView(
                constantLink: .oauthApplications,
                host: client.configuration.host
            )
            .environment(client)
        }
        .navigationTitle("API Configuration")
    }
}

#Preview {
    let client = try! Client()
    client.auth = OAuthToken(accessToken: "",
                             tokenType: "",
                             expiresIn: TimeInterval(60 * 60),
                             refreshToken: "",
                             scope: [],
                             createdAt: Date())
    return NavigationStack {
        DebugMenu()
            .environment(client)
    }
}
#endif
