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
    @State private var client: Client = {
        do {
            return try Client()
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    /// Set up SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bike.self,
            User.self,
            AuthenticatedUser.self,
            AutocompleteManufacturer.self,
            ScannedBike.self, // QR sticker history
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
        .modelContainer(sharedModelContainer)
    }

    private func handleDeeplink(_ url: URL?) {
        let scanResult = client.deeplinkManager.scan(url: url)
        if let sticker = scanResult?.scannedBike {
            do {
                let mainContext = sharedModelContainer.mainContext
                try mainContext.transaction {
                    // 1. Save the latest scanned bike sticker
                    mainContext.insert(sticker)

                    // 2. Purge any sticker outside of:
                    //      - scanned in the last 2 weeks
                    //      - scanned before the 10-most-recent
                    let bikesScannedInTheLastTwoWeeks = #Predicate<ScannedBike> { model in
                        model.createdAt > Date().addingTimeInterval(-60 * 60 * 24 * 14)
                    }
                    let sortByCreatedAt = SortDescriptor(\ScannedBike.createdAt,
                                                          order: .forward)
                    var fetchDescriptor = FetchDescriptor(predicate: bikesScannedInTheLastTwoWeeks,
                                                          sortBy: [sortByCreatedAt])
                    fetchDescriptor.fetchLimit = 10
                    let tenMostRecentStickers = try mainContext.fetchIdentifiers(fetchDescriptor)

                    try mainContext.delete(model: ScannedBike.self,
                                           where: #Predicate<ScannedBike> { model in
                        tenMostRecentStickers.contains(model.id) == false
                    })
                }
            } catch {
                Logger.model.error("\(error, privacy: .auto)")
            }
        }
    }
}
