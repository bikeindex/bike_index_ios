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
        let _ = Self._printChanges()
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
                    }
                }
            }
            .onChange(
                of: client.deeplinkManager.scannedBike, initial: true,
                { oldValue, newValue in
                    if let scan = newValue, navigator.wkWebView?.url != scan.url {
                        navigator.wkWebView?.load(URLRequest(url: scan.url))
                        title = scan.sticker.identifier
                    }

                    // TODO: Consider invalidating scannedBike, or leaving it in place for post-auth continuation.
                    // client.deeplinkManager.scannedBike = nil
                }
            )
        }
    }
}
