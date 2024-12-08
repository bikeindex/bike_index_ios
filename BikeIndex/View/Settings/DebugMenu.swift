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

    var body: some View {
        Form {
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
    return NavigationStack {
        DebugMenu()
            .environment(try! Client())
    }
}
#endif
