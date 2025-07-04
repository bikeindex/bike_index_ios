//
//  SettingsPage.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftUI

#if DEBUG
import PreviewGallery
#endif

struct SettingsPage: View {
    @Environment(Client.self) var client

    @State var iconsModel = AlternateIconsModel()
    @Binding var path: NavigationPath

    var body: some View {
        Form {
            if iconsModel.hasAlternates {
                Section {
                    NavigationLink(value: SettingsSelection.alternateIcons) {
                        Label {
                            Text("App Icon")
                        } icon: {
                            Image(uiImage: iconsModel.selectedAppIcon.image)
                                .appIcon(scale: .small)
                        }
                    }
                }
            }

            if client.authenticated {
                Section {
                    NavigationLink(value: SettingsSelection.userSettings) {
                        Label("User Settings", systemImage: "person.crop.circle")
                    }

                    NavigationLink(value: SettingsSelection.password) {
                        Label("Password", systemImage: "key")
                    }

                    NavigationLink(value: SettingsSelection.sharingPersonalPage) {
                        Label("Sharing + Personal Page", systemImage: "shared.with.you")
                    }

                    NavigationLink(value: SettingsSelection.registrationOrganization) {
                        Label(
                            "Registration Organization",
                            systemImage: "person.badge.shield.checkmark")
                    }

                    Button {
                        Task {
                            await logout()
                        }
                    } label: {
                        Label("Sign out", systemImage: "figure.walk.departure")
                            .tint(Color.highlightPrimary)
                            .foregroundStyle(Color.highlightPrimary)
                    }
                    .tint(Color.highlightPrimary)

                    NavigationLink(value: SettingsSelection.deleteAccount) {
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
                NavigationLink(value: SettingsSelection.debugMenu) {
                    Label("Debug menu", systemImage: "ladybug.circle")
                }
                NavigationLink(value: SettingsSelection.previewGallery) {
                    Label("Preview Gallery", systemImage: "eye.circle")
                }
                NavigationLink(value: SettingsSelection.databaseGallery) {
                    Label(
                        "Database Gallery",
                        systemImage: "cylinder.split.1x2")
                }
            } header: {
                Text("Developer")
            }
            #endif

            Section {
                Link(destination: MailToLink.contactUs.link) {
                    Label("Contact Us", systemImage: "envelope")
                }

                NavigationLink(value: SettingsSelection.acknowledgements) {
                    Label("Acknowledgements", systemImage: "character.book.closed")
                }

                NavigationLink(value: SettingsSelection.privacyPolicy) {
                    Label("Privacy Policy", systemImage: "shield.checkered")
                }

                NavigationLink(value: SettingsSelection.termsOfService) {
                    Label("Terms of Service", systemImage: "text.book.closed")
                }
            } header: {
                Text("About")
            } footer: {
                SettingsAttributionCaption()
            }
        }
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsSelection.self) { selection in
            switch selection {
            case .alternateIcons:
                AppIconPicker(model: $iconsModel)
            case .userSettings:
                NavigableWebView(
                    constantLink: .accountUserSettings,
                    host: client.configuration.host
                )
                .navigationTitle("User Settings")
            case .password:
                NavigableWebView(
                    constantLink: .accountPassword,
                    host: client.configuration.host
                )
                .navigationTitle("Password")
            case .sharingPersonalPage:
                NavigableWebView(
                    constantLink: .accountSharingPersonalPage,
                    host: client.configuration.host
                )
                .navigationTitle("Sharing + Personal Page")
            case .registrationOrganization:
                NavigableWebView(
                    constantLink: .accountRegistrationOrganization,
                    host: client.configuration.host
                )
                .navigationTitle("Registration Organization")
            case .deleteAccount:
                NavigableWebView(
                    constantLink: .deleteAccount,
                    host: client.configuration.host
                )
                .navigationTitle("Delete Account")
            #if DEBUG
            case .debugMenu:
                DebugMenu()
                    .environment(client)
            case .previewGallery:
                PreviewGallery()
            case .databaseGallery:
                DebugDataView()
            #endif
            case .acknowledgements:
                AcknowledgementsListView()
            case .privacyPolicy:
                NavigableWebView(
                    constantLink: .privacyPolicy,
                    host: client.configuration.host
                )
                .environment(client)
                .navigationTitle("Privacy Policy")
            case .termsOfService:
                NavigableWebView(
                    constantLink: .termsOfService,
                    host: client.configuration.host
                )
                .environment(client)
                .navigationTitle("Terms of Service")
            }
        }
    }

    func logout() async {
        path = NavigationPath()
        await client.destroySession()
    }

    /// Excluding signOut and contactUs which don't navigate internally
    enum SettingsSelection: Hashable, Identifiable {
        var id: Self { self }

        case alternateIcons
        case userSettings
        case password
        case sharingPersonalPage
        case registrationOrganization
        case deleteAccount
        #if DEBUG
        case debugMenu
        case previewGallery
        case databaseGallery
        #endif
        case acknowledgements
        case privacyPolicy
        case termsOfService
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        SettingsPage(
            iconsModel: AlternateIconsModel(),
            path: $path
        )
        .environment(try! Client())
    }
}

extension ClientConfiguration {
    fileprivate var oAuthLink: URL {
        host.appending(path: "oauth/applications")
    }
}
