//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftData
import SwiftUI
import OSLog

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
                        try! scannedBikesViewModel.handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        try! scannedBikesViewModel.handleDeeplink(userActivity.webpageURL)
                    }
            } else {
                AuthView()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        try! scannedBikesViewModel.handleDeeplink(url)
                    }
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        try! scannedBikesViewModel.handleDeeplink(userActivity.webpageURL)
                    }

            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }

    init() {
        let client = try! Client()
        self.client = client

        let schema = Schema([
            Bike.self,
            User.self,
            AuthenticatedUser.self,
            AutocompleteManufacturer.self,
            ScannedBike.self, // QR sticker history
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        self.sharedModelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])

        self.scannedBikesViewModel = .init(
            context: sharedModelContainer.mainContext,
            client: client
        )
    }
}

@MainActor
struct ScannedBikesViewModel {
    let context: ModelContext
    let client: Client

    init(context: ModelContext, client: Client) {
        self.context = context
        self.client = client
    }

    // TODO: Separate deeplinkManager.scan from database operations (separate functions)
    func handleDeeplink(_ url: URL?) throws {
        let scanResult = client.deeplinkManager.scan(url: url)
        if let sticker = scanResult?.scannedBike {

            // 1. Save the latest scanned bike sticker
            context.insert(sticker)
            try context.save()

            // 2. Purge any sticker outside of:
            //      - scanned in the last 2 weeks
            //      - scanned before the 10-most-recent
            let twoWeeksAgo = Date().addingTimeInterval(-60 * 60 * 24 * 14)
            let bikesScannedInTheLastTwoWeeks = #Predicate<ScannedBike> { model in
                model.createdAt > twoWeeksAgo
            }

            var fetchDescriptor = FetchDescriptor<ScannedBike>(
                predicate: bikesScannedInTheLastTwoWeeks,
                sortBy: [SortDescriptor(\.createdAt, order: .forward)])

            fetchDescriptor.fetchLimit = 10
            // Cannot use fetchIdentifiers _if_ the FetchDescriptor has a `sortBy` on a non-identifier field.
            let tenMostRecentStickers = try context.fetch(fetchDescriptor)
                .map(\.persistentModelID)

            try context.delete(model: ScannedBike.self,
                               where: #Predicate<ScannedBike> { model in
                tenMostRecentStickers.contains(model.persistentModelID) == false
            })
        }
    }
}
