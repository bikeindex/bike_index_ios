//
//  AuthSignInView.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import SwiftUI

struct AuthSignInView: View {
    @Environment(Client.self) var client
    @Environment(QRStickerRouter.self) var stickerRouter
    @State var baseUrl: URL
    var navigator: HistoryNavigator
    @Binding var display: Bool
    @State private var title: String = "Sign in"

    var body: some View {
        @Bindable var stickerRouter = stickerRouter
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
                        /// Because the user dismissed the sign-in page, clear the manager
                        /// so they can open any subsequent universal link
                        stickerRouter.closeStickerCenter()
                    }
                }
            }
        }
    }
}
