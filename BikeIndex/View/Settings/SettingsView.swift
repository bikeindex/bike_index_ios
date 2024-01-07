//
//  SettingsView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import OSLog

struct SettingsView: View {
    @Environment(Client.self) var client

    @State var iconsModel = AlternateIconsModel()

    var body: some View {
        Form {
            if iconsModel.hasAlternates {
                Section {
                    NavigationLink {
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

            if client.authenticated {
                Section {
                    Button(action: client.destroySession) {
                        Label("Sign out", systemImage: "figure.walk.departure")
                    }
                }
            }

            NavigationLink {
                DebugMenu()
            } label: {
                Label("Debug menu", systemImage: "ladybug.circle")
            }


            Section {
                AcknowledgementsView()
            } header: {
                Text("Acknowledgements")
            }

            Section {
                EmptyView()
            } footer: {
                HStack {
                    Spacer()
                    Text("Made with 💝 in Pittsburgh, PA")
                    Spacer()
                }
            }

        }
        .navigationTitle("Settings")
    }
}

#Preview {
    return NavigationStack {
        SettingsView(iconsModel: AlternateIconsModel())
            .environment(try! Client())
    }
}

fileprivate extension ClientConfiguration {
    var oAuthLink: URL {
        host.appending(path: "oauth/applications")
    }
}
