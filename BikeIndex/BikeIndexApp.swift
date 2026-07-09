//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import AppIntents
import HoneybadgerSwift
import OSLog
import SwiftData
import SwiftUI

@main
struct BikeIndexApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    /// A Client instance for stateful networking.
    @State private var client: Client
    @State private var qrStickerRouter: QRStickerRouter

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
            .onOpenURL(perform: handleUniversalLink)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
                handleUniversalLink($0.webpageURL)
            }
            .environment(client)
            .environment(qrStickerRouter)
            .modelContainer(sharedModelContainer)
        }
    }

    /// DeeplinkManager parses out the URL and returns a boxed result.
    /// If this boxed result contains a QR sticker scanned bike then the view model will persist it.
    /// After the view model persists the QR sticker, it can be stored in DeeplinkManager as the most-recent.
    private func handleUniversalLink(_ url: URL?) {
        let stickerParser = StickerParser(host: client.hostProvider)
        guard let scannedBike = stickerParser.scan(url: url) else {
            Logger.model.error("Failed to handle deeplink: \(String(describing: url))")
            Honeybadger.notify(
                errorString: "Failed to handle deeplink \(String(describing: url))",
                context: [
                    Honeybadger.ContextKey.deeplink.rawValue: url?.description ?? ""
                ])
            return
        }
        do {
            let scannedBikesViewModel = StickerCenter.ViewModel()
            let persistedSticker = try scannedBikesViewModel.persist(
                context: sharedModelContainer.mainContext,
                sticker: scannedBike)
            qrStickerRouter.scanUniversalLink(persistedSticker)
        } catch {
            Logger.deeplinks.error(
                "Failed to scan QR sticker from deeplink code \(scannedBike.sticker, privacy: .auto)"
            )
            Honeybadger.notify(error: error, qrSticker: scannedBike.sticker)
        }
    }

    init() {
        let client = try! Client()
        self.client = client
        self.qrStickerRouter = QRStickerRouter()

        Honeybadger.configure(apiKey: client.configuration.honeybadgerApiKey)

        let schema = Schema([
            Bike.self,
            User.self,
            AuthenticatedUser.self,
            AutocompleteManufacturer.self,
            ScannedSticker.self,  // QR sticker history
            FullPublicImage.self,
            StolenBikeRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let sharedModelContainer = try ModelContainer(
                for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = sharedModelContainer
        } catch {
            Honeybadger.notify(error: error)
            print(error)
            fatalError(error.localizedDescription)
        }

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
