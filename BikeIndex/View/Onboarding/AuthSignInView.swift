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
    var title: String
    // TODO: Move to ViewModel?

    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            NavigableWebView(
                url: $baseUrl,
                navigator: navigator)
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
            .onChange(of: client.deeplinkModel, initial: true, { oldValue, newValue in
                if let deeplinkModel = newValue?.scannedBike()?.url,
                   navigator.wkWebView?.url != deeplinkModel {
                    navigator.wkWebView?.load(URLRequest(url: deeplinkModel))
                } else {
                    print("CHange, but not on client.deeplinkModel")
                }
            })
        }
    }
}

