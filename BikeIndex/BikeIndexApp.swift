//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftData
import SwiftUI

@main
struct BikeIndexApp: App {
    /// A Client instance for stateful networking.
    @State private var client: Client
    /// A database helper to manage bike stickers.
    @State private var scannedBikesViewModel: ScannedBikesViewModel

    /// Set up SwiftData
    var sharedModelContainer: ModelContainer

    /// Set up App
    /// NOTE: MainContentPage and AuthView **each** implement their own universal link handling.
    /// Scene does not implement `onOpenURL` so each applies a basic handler to kickstart the process.
    var body: some Scene {
        WindowGroup {
            if client.authenticated {
                MainContentPage()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        handleDeeplink(userActivity.webpageURL)
                    }
            } else {
                AuthView()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        handleDeeplink(userActivity.webpageURL)
                    }

            }
        }
        .environment(client)
        .environment(scannedBikesViewModel)
        .modelContainer(sharedModelContainer)
    }

    /// DeeplinkManager parses out the URL and returns a boxed result.
    /// If this boxed result contains a QR sticker scanned bike then the view model will persist it.
    /// After the view model persists the QR sticker, it can be stored in DeeplinkManager as the most-recent.
    private func handleDeeplink(_ url: URL?) {
        let scanResult = client.deeplinkManager.scan(url: url)
        do {
            if let sticker = scanResult?.scannedBike {
                let persistedSticker = try scannedBikesViewModel.persist(sticker: sticker)
                client.deeplinkManager.scannedBike = persistedSticker
            }
        } catch {
            Logger.model.error("Failed to handle deeplink: \(error)")
        }
    }

    init() {
        let client = try! Client()
        self.client = client

        let schema = Schema([
            Bike.self,
            User.self,
            AuthenticatedUser.self,
            AutocompleteManufacturer.self,
            ScannedBike.self,  // QR sticker history
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let sharedModelContainer =  try! ModelContainer(
            for: schema, configurations: [modelConfiguration])
        self.sharedModelContainer = sharedModelContainer

        let scannedBikesViewModel = ScannedBikesViewModel(
            context: sharedModelContainer.mainContext,
            client: client
        )
        self.scannedBikesViewModel = scannedBikesViewModel
    }
}
