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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// Set up App
    var body: some Scene {
        WindowGroup {
            Group {
                if client.authenticated {
                    MainContentPage()
                        .tint(Color.accentColor)
                } else {
                    AuthView()
                        .tint(Color.accentColor)
                    // TODO: Consider separating onOpenURL behavior by authenticated vs guest here to build everything without overloading and conflicting behavior
                }
            }
            .sheet(item: $client.deeplinkModel, content: { deeplinkModel in
                if let deeplink = deeplinkModel.scannedBike() {
                    ScannedBikePage(scan: deeplink)
                        .environment(client)
                }
            })
            .onOpenURL { deeplinkURL in
                print("URL is \(deeplinkURL)")
                // TODO: Test with `xcrun simctl openurl booted "bikeindex://https://bikeindex.org/bikes/scanned/A40340"`
                client.deeplinkModel = DeeplinkModel(scannedURL: deeplinkURL)
            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }
}
