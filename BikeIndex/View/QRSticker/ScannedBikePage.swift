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
        }
        .task {
            await viewModel.fetchScanDetails(client: client, modelContext: modelContext)
        }
    }
}

extension ScannedBikePage {
    @MainActor @Observable
    final class ViewModel {
        var scan: ScannedBike

        var title: String {
            scan.displayTitle.trimmingCharacters(in: .whitespaces)
        }

        init(scan: ScannedBike) {
            self.scan = scan
        }

        func fetchScanDetails(client: Client, modelContext: ModelContext) async {
            guard scan.bike == nil else {
                Logger.model.info(
                    "ScannedBikePage.ViewModel attempted to fetch bike details for \(self.scan.sticker) but the associated bike was already fetched and is known in the database, skipping fetch."
                )
                return
            }

            let stickerId = scan.sticker
            let fullBikeResponseContainer = await client.get(Bikes.scanned(sticker: stickerId))
            switch fullBikeResponseContainer {
            case .success(let success):
                Logger.api.info(
                    "Fetched bike details from sticker \(self.scan.sticker), \(String(describing: success))"
                )

                guard let responseContainer = success as? FullBikeResponseContainer else {
                    Logger.api.error(
                        "Failed to fetch full bike details for scanned sticker \(self.scan.sticker)"
                    )
                    Honeybadger.notify(
                        errorString:
                            "Failed to parse FullBikeResponseContainer for associated sticker",
                        context: [
                            Honeybadger.ContextKey.qrSticker.rawValue: scan.sticker
                        ])
                    return
                }

                let bike = responseContainer.bike.modelInstance()
                do {
                    try modelContext.transaction {
                        modelContext.insert(bike)
                        bike.scannedSticker = scan
                        scan.bike = bike
                        modelContext.insert(scan)
                    }
                } catch {
                    Logger.api.error(
                        "Failed to fetch full details for scanned sticker \(self.scan.sticker) due to \(error)"
                    )
                    Honeybadger.notify(error: error, qrSticker: scan.sticker)
                }

            case .failure(let failure):
                Logger.api.error(
                    "Failed to fetch full details for scanned sticker \(self.scan.sticker) due to \(failure)"
                )
                Honeybadger.notify(error: failure, qrSticker: scan.sticker)
            }
        }
    }
}
