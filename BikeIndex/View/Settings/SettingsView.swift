//
//  SettingsView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import OSLog
#if DEBUG
import PreviewGallery
#endif

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
                        Label(title: { Text("App Icon") }, icon: {
                            Image(uiImage: iconsModel.selectedAppIcon.image)
                                .appIcon(scale: .small)
                        })
                    }
                }
            }

            if client.authenticated {
                Section {
                    NavigationLink {
                        NavigableWebView(
                            constantLink: .accountUserSettings,
                            host: client.configuration.host
                        )
                        .navigationTitle("User Settings")
                    } label: {
                        Label("User Settings", systemImage: "person.crop.circle")
                    }

                    NavigationLink {
                        NavigableWebView(
                            constantLink: .accountPassword,
                            host: client.configuration.host
                        )
                        .navigationTitle("Password")
                    } label: {
                        Label("Password", systemImage: "key")
                    }

                    NavigationLink {
                        NavigableWebView(
                            constantLink: .accountSharingPersonalPage,
                            host: client.configuration.host
                        )
                        .navigationTitle("Sharing + Personal Page")
                    } label: {
                        Label("Sharing + Personal Page", systemImage: "shared.with.you")
                    }

                    NavigationLink {
                        NavigableWebView(
                            constantLink: .accountRegistrationOrganization,
                            host: client.configuration.host
                        )
                        .navigationTitle("Registration Organization")
                    } label: {
                        Label("Registration Organization", systemImage: "person.badge.shield.checkmark")
                    }

                    Button(action: client.destroySession) {
                        // Hack in an empty destination to achieve the disclosure indicator
                        NavigationLink(destination: EmptyView()) {
                            Label("Sign out", systemImage: "figure.walk.departure")
                                .tint(Color.highlightPrimary)
                                .foregroundStyle(Color.highlightPrimary)
                        }
                    }
                    .tint(Color.highlightPrimary)

                    NavigationLink {
                        NavigableWebView(
                            constantLink: .deleteAccount,
                            host: client.configuration.host
                        )
                        .navigationTitle("Delete Account")
                    } label: {
                        Label("Delete Account", systemImage: "trash.fill")
                            .tint(Color.highlightPrimary)
                            .foregroundStyle(Color.highlightPrimary)
                    }
                    .tint(Color.highlightPrimary)
                } header: {
                    Text("Manage Account")
                }
            }

            #if DEBUG
            Section {
                NavigationLink {
                    DebugMenu()
                        .environment(client)
                } label: {
                    Label("Debug menu", systemImage: "ladybug.circle")
                }
                NavigationLink {
                    PreviewGallery()
                } label: {
                    Label("Preview Gallery", systemImage: "eye.circle")
                }
            } header: {
                Text("Developer")
            }
            #endif

            Section {
                Button("Contact Us", systemImage: "envelope") {
                    /// Access openURL directly.
                    /// If ``SettingsView`` captures the Environment object in a var it will conflict with the
                    /// NavigationLink's web views and cause an infinite loop. (I think that's the cause).
                    Environment(\.openURL).wrappedValue(MailToLink.contactUs.link)
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink {
                    AcknowledgementsListView()
                } label: {
                    Label("Acknowledgements", systemImage: "character.book.closed")
                }
                NavigationLink {
                    NavigableWebView(
                        constantLink: .privacyPolicy,
                        host: client.configuration.host
                    )
                    .navigationTitle("Privacy Policy")
                } label: {
                    Label("Privacy Policy", systemImage: "shield.checkered")
                }
                NavigationLink {
                    NavigableWebView(
                        constantLink: .termsOfService,
                        host: client.configuration.host
                    )
                    .navigationTitle("Terms of Service")
                } label: {
                    Label("Terms of Service", systemImage: "text.book.closed")
                }
            }
            header: {
                Text("About")
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
