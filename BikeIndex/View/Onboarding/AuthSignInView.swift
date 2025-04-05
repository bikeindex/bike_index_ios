//
//  AuthSignInView.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import SwiftUI

struct AuthSignInView: View {
    @Environment(Client.self) var client
    @State var baseUrl: URL
    var navigator: HistoryNavigator
    @Binding var display: Bool
    @State private var title: String = "Sign in"

    var body: some View {
        @Bindable var deeplinkManager = client.deeplinkManager
        NavigationStack {
            NavigableWebView(
                url: $baseUrl,
                navigator: navigator
            )
            .environment(client)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        display = false
                        /// Because the user dismissed the page, clear the manager
                        /// so they can open any subsequent universal link
                        deeplinkManager.scannedBike = nil
                    }
                }
            }
            .onChange(
                of: deeplinkManager.scannedBike, initial: true,
                { oldValue, newValue in
                    /// NOTE: After a scanned bike is displayed in the webview, _do not_ invalidate it.
                    /// This allows post-sign-in flows to resume displaying the universal link until
                    /// the user decides to dismiss it.
                    if let scan = newValue, navigator.wkWebView?.url != scan.url {
                        navigator.wkWebView?.load(URLRequest(url: scan.url))
                        title = scan.sticker.identifier
                    }
                }
            )
        }
    }
}
