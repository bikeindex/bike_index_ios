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
                        // Hack in an empty destination to achieve the disclosure indicator
                        NavigationLink(destination: EmptyView()) {
                            Label("Sign out", systemImage: "figure.walk.departure")
                                .tint(Color.highlightPrimary)
                                .foregroundStyle(Color.highlightPrimary)
                        }
                    }
                    .tint(Color.highlightPrimary)
                }
            }

            #if DEBUG
            NavigationLink {
                DebugMenu()
                    .environment(client)
            } label: {
                Label("Debug menu", systemImage: "ladybug.circle")
            }
            #endif

            Section {
                NavigationLink {
                    AcknowledgementsListView()
                } label: {
                    Label("Acknowledgements", systemImage: "character.book.closed")
                }
                NavigationLink {
                    NavigableWebView(url: BikeIndexLink.privacyPolicy.link(base: client.configuration.host))
                        .navigationTitle("Privacy Policy")
                } label: {
                    Label("Privacy Policy", systemImage: "shield.checkered")
                }
                NavigationLink {
                    NavigableWebView(url: BikeIndexLink.termsOfService.link(base: client.configuration.host))
                        .navigationTitle("Terms of Service")
                } label: {
                    Label("Terms of Service", systemImage: "text.book.closed")
                }
            }

            footer: {
                HStack {
                    Spacer()
                    Text("Made with 💝 in Pittsburgh, PA")
                    Spacer()
                }
                .padding(.top)
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
