//
//  ScannedBikePage.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import Honeybadger
import OSLog
import SwiftData
import SwiftUI
import WebKit

/// For authenticated users, display the Bike Sticker details page for the scanned sticker.
/// In the future the web view's Navigator parameter can be used to provide custom behavior
/// for bike sticker -> registration links and bike sticker -> bike details links.
struct ScannedBikePage: View {
    @Environment(Client.self) var client
    @Environment(\.modelContext) var modelContext: ModelContext
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
            do {
                try viewModel.fetchScanDetails(modelContext: modelContext)
            } catch {
                Logger.api.error(
                    "Failed to fetch full details for scanned sticker \(viewModel.scan.sticker)")
                Honeybadger.notify(error: error, qrSticker: viewModel.scan.sticker)
            }
        }
    }
}

extension ScannedBikePage {
    @Observable
    final class ViewModel {
        var scan: ScannedBike

        var title: String {
            scan.displayTitle.trimmingCharacters(in: .whitespaces)
        }

        init(scan: ScannedBike) {
            self.scan = scan
        }

        func fetchScanDetails(modelContext: ModelContext) throws {
            // TODO: Fill in Bikes.scanned(sticker) fetch and persistence
        }
    }
}
