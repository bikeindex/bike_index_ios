//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData

@main
struct BikeIndexApp: App {
    @State private var client: Client = {
        do {
            return try Client()
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bike.self,
            User.self,
            AuthenticatedUser.self,
            AutocompleteManufacturer.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if client.authenticated {
                ContentView()
                    .task {
                        client.fetchProfile(context: sharedModelContainer.mainContext)
                    }
            } else {
                AuthView()
            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }
}
