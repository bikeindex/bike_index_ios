//
//  ScannedBikePage.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import OSLog
import SwiftUI
import WebKit

/// For authenticated users, display the Bike Sticker details page for the scanned sticker.
/// In the future the web view's Navigator parameter can be used to provide custom behavior
/// for bike sticker -> registration links and bike sticker -> bike details links.
struct ScannedBikePage: View {
    @Environment(Client.self) var client
    @State var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            NavigableWebView(
                url: .constant(viewModel.scan.url)
            )
            .environment(client)
            .navigationTitle(viewModel.title)
            .toolbar {
                if viewModel.dismiss != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") {
                            viewModel.dismiss?()
                        }
                    }
                }
            }
            .onAppear {
                Logger.views.debug(
                    "ScannedBikePage opening sticker for \(viewModel.scan.url) -- \\(viewModel.scan.persistentModelID)"
                )
            }
        }
    }
}

extension ScannedBikePage {
    @Observable
    final class ViewModel {
        var scan: ScannedBike
        var path: NavigationPath
        var dismiss: (() -> Void)?
        // TODO: onDisappear needs to be connected to NavigableWebView.navigator actions for /register URLs
        var onDisappear: MainContent?

        var title: String {
            scan.displayTitle.trimmingCharacters(in: .whitespaces)
        }

        init(scan: ScannedBike, path: NavigationPath, dismiss: (() -> Void)?) {
            self.scan = scan
            self.path = path
            self.dismiss = dismiss
        }
    }
}
