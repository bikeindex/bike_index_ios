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
        NavigableWebView(
            url: .constant(viewModel.scan.url)
        )
        .environment(client)
        .navigationTitle(viewModel.title)
        .onAppear {
            Logger.views.debug(
                "ScannedBikePage opening sticker for \(viewModel.scan.url)"
            )
        }
    }
}

extension ScannedBikePage {
    @Observable
    final class ViewModel {
        var scan: ScannedSticker

        var title: String {
            scan.displayTitle.trimmingCharacters(in: .whitespaces)
        }

        init(scan: ScannedSticker) {
            self.scan = scan
        }
    }
}
