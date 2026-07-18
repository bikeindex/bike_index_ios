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
    @Environment(QRStickerRouter.self) var stickerRouter
    /// ViewModel to manage state.
    /// `viewModel.authNavigator.client` must be connected at runtime.
    @State private var viewModel = ViewModel()

    var body: some View {
        @Bindable var stickerRouter = stickerRouter
        NavigationStack(path: $viewModel.topLevelPath) {
            WelcomeView(
                displaySignIn: $viewModel.displaySignIn,
            )
            .toolbar {
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
            isPresented: $viewModel.displaySignIn,
            onDismiss: {
                // Essential to reset state
                viewModel.historyNavigator.wkWebView?.load(
                    URLRequest(url: URL(stringLiteral: "about:blank")))
            },
            content: {
                // Sign-in Dialog.
                // Also supports QR-code bike display in a web view.
                AuthSignInView(
                    baseUrl: viewModel.signInPageRequest.url!,
                    // pre-condition: historyNavigator.child is assigned to viewModel.authNavigator
                    navigator: viewModel.historyNavigator,
                    display: $viewModel.displaySignIn
                )
                .environment(client)
                .environment(stickerRouter)
                .interactiveDismissDisabled()
            }
        )
        .fullScreenCover(isPresented: $stickerRouter.displayStickerCenter) {
            StickerCenter()
                .environment(client)
                .environment(stickerRouter)
        }
        .onAppear {
            /// Connect AuthView.viewModel.authenticationNavigator.client at runtime
            /// so that AuthenticationNavigator can respond to sign-in and complete the flow.
            viewModel.assign(client: client)
        }
    }
}

#Preview {
    @Previewable let client = try! Client()
    @Previewable let stickerRouter = QRStickerRouter()
    AuthView()
        .environment(client)
        .environment(stickerRouter)
}
