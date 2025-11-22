//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import AppIntents
import OSLog
import SwiftData
import SwiftUI

@main
struct BikeIndexApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    /// A Client instance for stateful networking.
    @State private var client: Client

    /// Set up SwiftData
    private var sharedModelContainer: ModelContainer

    /// Set up App
    /// NOTE: MainContentPage and AuthView **each** implement their own universal link handling.
    /// Scene does not implement `onOpenURL` so each applies a basic handler to kickstart the process.
    var body: some Scene {
        WindowGroup {
            Group {
                if client.authenticated {
                    MainContentPage()
                } else {
                    AuthView()
                }
            }
            .tint(.accentColor)
            .onOpenURL(perform: handleDeeplink)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { handleDeeplink($0.webpageURL) }
            .environment(client)
            .modelContainer(sharedModelContainer)
        }
    }

    /// DeeplinkManager parses out the URL and returns a boxed result.
    /// If this boxed result contains a QR sticker scanned bike then the view model will persist it.
    /// After the view model persists the QR sticker, it can be stored in DeeplinkManager as the most-recent.
    private func handleDeeplink(_ url: URL?) {
        let scanResult = client.deeplinkManager.scan(url: url)
        do {
            if let sticker = scanResult?.scannedBike {
                let scannedBikesViewModel = RecentlyScannedStickersView.ViewModel()
                let persistedSticker = try scannedBikesViewModel.persist(
                    context: sharedModelContainer.mainContext,
                    sticker: sticker)
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

        let sharedModelContainer = try! ModelContainer(
            for: schema, configurations: [modelConfiguration])
        self.sharedModelContainer = sharedModelContainer

        // Give AppDelegate access to client's background session delegate
        appDelegate.backgroundSessionDelegate = client.backgroundSessionDelegate

        setupAppIntentsDependancies()
    }

    // MARK: - App Intents Setup

    /// Registers the app's `ModelContainer` with the `AppDependencyManager`
    /// This allows App Intents (such as Siri and Shortcuts) to access SwiftData models.
    func setupAppIntentsDependancies() {
        AppDependencyManager.shared.add(key: "ModelContainer", dependency: sharedModelContainer)
        BikeIndexShortcutsProvider.updateAppShortcutParameters()
    }
}
