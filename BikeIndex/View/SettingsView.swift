//
//  SettingsView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(Client.self) var client
    @State var iconsModel = AlternateIconsModel()

    @State var secretHidden = true

    var body: some View {
        Form {
            if iconsModel.hasAlternates {
                Section {
                    NavigationLink {
                        // TODO: This navigation link is wrong and
                        AppIconPicker(model: $iconsModel)
                    } label: {
                        if let uiImage = UIImage(named: iconsModel.selectedAppIcon.rawValue) {
                            Label(title: { Text("App Icon") }, icon: {
                                Image(uiImage: uiImage)
                                    .appIcon(scale: .small)
                            })
                        } else {
                            Label("App Icon", systemImage: iconsModel.absentIcon)
                        }
                    }
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
                            .toggleStyle(.switch)
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
    return SettingsView(iconsModel: AlternateIconsModel())
        .environment(try! Client())
}
