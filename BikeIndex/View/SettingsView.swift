//
//  SettingsView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(Client.self) var client

    @State var secretHidden = true

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
                    // NOTE: ClientConfiguration only supports Scope.allCases at this time
                    HStack {
                        Text("`\(scope.rawValue)`")
                    }
                }
            } header: {
                Text("OAuth")
            } footer: {
                Text("[Edit your OAuth Applications at bikeindex.org](\(client.configuration.host)/oauth/applications)")
            }

            if client.authenticated {
                Section {
                    Button(action: client.destroySession) {
                        Label("Sign out", systemImage: "figure.walk.departure")
                    }
                }
            }
        }
        .navigationTitle("BikeIndex Settings")
    }
}

#Preview {
    return SettingsView()
        .environment(try! Client())
}
