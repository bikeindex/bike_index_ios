//
//  BikeIndexApp.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import FontKit
import FontOpenSans

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
            Organization.self,
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

    init() {
        FontKit.registerOpenSans()
    }

    var body: some Scene {
        WindowGroup {
            if client.authenticated {
                ContentView()
                    .tint(Color.accentColor)
            } else {
                AuthView()
                    .tint(Color.accentColor)
            }
        }
        .environment(client)
        .modelContainer(sharedModelContainer)
    }
}
