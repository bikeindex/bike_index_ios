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
    /// Create a Client instance for stateful networking.
    @State private var client: Client
    /// Set up SwiftData
    var sharedModelContainer: ModelContainer
    ///
    var scannedBikesViewModel: ScannedBikesViewModel

    /// Set up App
    /// NOTE: MainContentPage and AuthView **each** implement their own universal link handling.
    /// Scene does not implement `onOpenURL` so each applies a basic handler to kickstart the process.
    var body: some Scene {
        WindowGroup {
            if client.authenticated {
                MainContentPage()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        try! handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        try! handleDeeplink(userActivity.webpageURL)
                    }
            } else {
                AuthView()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        try! handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        try! handleDeeplink(userActivity.webpageURL)
                    }

            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }

    func handleDeeplink(_ url: URL?) throws {
        let scanResult = client.deeplinkManager.scan(url: url)
        if let sticker = scanResult?.scannedBike {
            try scannedBikesViewModel.persist(sticker: sticker)
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

        self.sharedModelContainer = try! ModelContainer(
            for: schema, configurations: [modelConfiguration])

        self.scannedBikesViewModel = .init(
            context: sharedModelContainer.mainContext,
            client: client
        )
    }
}
