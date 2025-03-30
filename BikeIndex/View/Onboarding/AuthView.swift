//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftUI
import WebKit
import WebViewKit

/// NOTE: Network traffic for ASWebAuthenticationSession will run in the WebKitNetworking process!
/// This means that Proxyman will not show app authentication in the "Bike Index" app. You will have to look for the
/// host or across all networking in Proxyman!
/// Entry-point for all users to sign-in.
struct AuthView: View {
    /// API client for performing auth
    @Environment(Client.self) var client
    /// ViewModel to manage state.
    /// `viewModel.authNavigator.client` must be connected at runtime.
    @State private var viewModel = ViewModel()

    var body: some View {
        @Bindable var boundClient = client
        NavigationStack(path: $viewModel.topLevelPath) {
            WelcomeView()
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            viewModel.display = true
                        } label: {
                            Label(
                                "Sign in and get started",
                                systemImage: "person.crop.circle.dashed"
                            )
                            .accessibilityIdentifier("SignIn")
                            .font(.title3)
                            .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    ToolbarItemGroup(placement: .topBarLeading) {
                        #if DEBUG
                        NavigationLink(value: ViewModel.Nav.debugSettings) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        #endif
                        NavigationLink(value: ViewModel.Nav.help) {
                            Label("Help", systemImage: "book.closed")
                        }
                    }
                }
                .navigationTitle("Welcome to Bike Index")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ViewModel.Nav.self) { navSelection in
                    switch navSelection {
                    case .debugSettings:
                        SettingsPage(path: $viewModel.topLevelPath)
                            .environment(client)
                            .accessibilityIdentifier("Settings")
                    case .help:
                        NavigableWebView(constantLink: .help, host: client.configuration.host)
                            .environment(client)
                            .navigationTitle("Help")
                    }
                }
        }
        .sheet(isPresented: $viewModel.display, onDismiss: {

        }, content: {
            // Sign-in Dialog.
            // Also supports QR-code bike display in a web view.
            // TODO: Change $viewModel.display back to bool -- this way when the QR code > sign-in > change can *keep* the same web view and history, and just go to a new page.
            AuthSignInView(baseUrl: viewModel.oAuthUrl.unsafelyUnwrapped,
                           navigator: viewModel.authNavigator,
                           display: $viewModel.display,
                           title: "Sign In")
            .environment(client)
            .onAppear {
                viewModel.authNavigator.routeToAuthenticationPage = {
//                    viewModel.navigationUrl = viewModel.oAuthUrl.unsafelyUnwrapped
                    viewModel.authNavigator.wkWebView?.load(URLRequest(url: viewModel.oAuthUrl.unsafelyUnwrapped))
                }
            }
        })
        .onAppear {
            viewModel.authNavigator.client = client
        }
        .onOpenURL { url in
            client.deeplinkModel = DeeplinkModel(scannedURL: url)
            if let deeplink = client.deeplinkModel?.scannedBike()?.url,
                viewModel.display == false {
                print("@@ Client deeplink is \(deeplink)")
                viewModel.display = true
//                if viewModel.authNavigator.wkWebView?.url != deeplink {
//                    viewModel.authNavigator.wkWebView?.load(URLRequest(url: deeplink))
//                }
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
