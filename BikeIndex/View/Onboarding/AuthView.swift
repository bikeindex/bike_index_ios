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
        .sheet(
            isPresented: $viewModel.display,
            onDismiss: {
                // Essential to reset state
                viewModel.historyNavigator.wkWebView?.load(URLRequest(url: URL("about:blank")))
            },
            content: {
                // Sign-in Dialog.
                // Also supports QR-code bike display in a web view.
                // TODO: Change $viewModel.display back to bool -- this way when the QR code > sign-in > change can *keep* the same web view and history, and just go to a new page.
                AuthSignInView(
                    baseUrl: viewModel.oAuthUrl.unsafelyUnwrapped,
                    navigator: viewModel.historyNavigator,
                    display: $viewModel.display
                )
                .environment(client)
                .interactiveDismissDisabled()
                .onAppear {
                    viewModel.authNavigator?.routeToAuthenticationPage = {
                        viewModel.historyNavigator.wkWebView?.load(
                            URLRequest(url: viewModel.oAuthUrl.unsafelyUnwrapped))
                    }
                }
            }
        )
        .onAppear {
            /// Connect AuthView.viewModel.authenticationNavigator.client at runtime
            /// so that AuthenticationNavigator can respond to sign-in and complete the flow.
            viewModel.authNavigator?.client = client
        }
        .onOpenURL { url in
            ///
            viewModel.display = true

            client.deeplinkManager.scannedBike = ScannedBike(url: url)

            Logger.deeplinks.info(
                "AuthView handling scanned deeplink: \(String(describing: client.deeplinkManager.scannedBike?.url))"
            )
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
