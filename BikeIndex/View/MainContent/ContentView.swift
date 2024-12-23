//
//  ContentView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    // Control the navigation hierarchy for all views after this one
    @State var path = NavigationPath()

    // Internal display
    var contentModel = ContentModel()

    @Query private var bikes: [Bike]
    @Query private var authenticatedUsers: [AuthenticatedUser]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in
                        ContentButtonView(path: $path,
                                          item: menuItem)
                    }
                }

                if bikes.isEmpty {
                    ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle")
                        .padding()
                } else {
                    ProportionalLazyVGrid {
                        ForEach(Array(bikes.enumerated()), id: \.element) { (index, bike) in
                            ContentBikeButtonView(path: $path, bike: bike)
                                .accessibilityIdentifier("Bike \(index + 1)")
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                MainToolbar(path: $path)
            }
            .navigationTitle("Bike Index")
            .navigationDestination(for: MainContent.self) { selection in
                switch selection {
                case .settings:
                    SettingsView()
                        .accessibilityIdentifier("Settings")
                case .registerBike:
                    RegisterBikeView(mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(mode: .myStolenBike)
                case .searchBikes:
                    NavigableWebView(url: .constant(URL(string: "https://bikeindex.org/bikes?stolenness=all")!))
                        .environment(client)
                }
            }
            .navigationDestination(for: PersistentIdentifier.self) { identifier in
                if let bike = bikes.first(where: { $0.persistentModelID == identifier }) {
                    BikeDetailView(bike: bike)
                }
            }
        }
       .task {
           await contentModel.fetchProfile(client: client,
                                           modelContext: modelContext)
           await contentModel.fetchBikes(client: client,
                                         modelContext: modelContext)
        }
    }
}



// MARK: - Previews

#Preview("Empty data") {
    // MARK: Empty Data Preview
    do {
        let client = try Client()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
                                           configurations: config)

        return ContentView()
            .environment(client)
            .modelContainer(container)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}

#Preview("1 Bike Preview") {
    // MARK: 1 Bike Preview
    do {
        let client = try Client()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
                                           configurations: config)

        let rawJsonData = MockData.sampleBikeJson.data(using: .utf8)!
        let output = try JSONDecoder().decode(BikeResponse.self, from: rawJsonData)
        let bike = output.modelInstance()

        container.mainContext.insert(bike)
        try? container.mainContext.save()

        return ContentView()
            .environment(client)
            .modelContainer(container)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
