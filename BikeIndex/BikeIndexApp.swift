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
    /// NOTE: MainContentPage and AuthView **each** implement their own universal link handling
    var body: some Scene {
        WindowGroup {
            if client.authenticated {
                MainContentPage()
                    .tint(Color.accentColor)
                    .onOpenURL { url in
                        client.deeplinkModel = DeeplinkModel(scannedURL: url)
                    }
            } else {
                AuthView()
                    .tint(Color.accentColor)
            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }
}
