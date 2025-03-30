//
//  AuthSignInView.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import SwiftUI

struct AuthSignInView: View {
    @Environment(Client.self) var client
    @Binding var oAuthUrl: URL
    var navigator: AuthenticationNavigator
    @Binding var displayMode: AuthView.ViewModel.Sheet?
    var title: String
    // TODO: Move to ViewModel?

    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            NavigableWebView(
                url: $oAuthUrl,
                navigator: HistoryNavigator(child: navigator))
            .environment(client)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        displayMode = nil
                    }
                }
            }
            .onAppear {
                navigator.routeToAuthenticationPage = {
                    displayMode = .displaySignIn
                }
            }
        }
    }
}

