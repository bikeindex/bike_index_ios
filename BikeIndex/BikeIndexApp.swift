//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftData
import SwiftUI

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
            // TODO: Add ScannedBike
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
            // Persist to SwiftData after previous changes have more confidence.
//            sharedModelContainer.mainContext.insert(sticker)
        }
    }
}
