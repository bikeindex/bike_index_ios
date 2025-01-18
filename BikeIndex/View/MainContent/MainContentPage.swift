//
//  MainContentPage.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import OSLog

struct MainContentPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    // Control the navigation hierarchy for all views after this one
    @State var path = NavigationPath()

    // Data handling and error handling
    var contentModel = MainContentModel()
    @State var lastError: MainContentModel.Error?
    @State var showError: Bool = false

    @Query private var bikes: [Bike]

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
                            ContentBikeButtonView(
                                path: $path,
                                bikeIdentifier: bike.identifier
                            )
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
                    SettingsPage(path: $path)
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
            .alert(isPresented: $showError, error: lastError) {
                Text("Error occurred")
            }
        }
       .task {
           await fetchMainContentData()
        }
    }

    /// 1. Fetch profile data
    ///     - Report error and return if any problems occur
    /// 2. Fetch profile's bikes data
    ///     - Report error and return if any problems occur
    /// Unfortunately I don't see any way around the Xcode 16.0 / Swift 6 "'as' test is always true" compiler warning.
    /// Resources:
    /// - https://stackoverflow.com/questions/79019378/swift-6-how-to-use-typed-throws-inside-a-task
    /// - https://dandylyons.github.io/posts/typed-error-handling/
    /// - https://forums.swift.org/t/struct-mystruct-error-does-not-conform-to-errorcodeprotocol/17103
    /// - https://www.hackingwithswift.com/swift/6.0/typed-throws
    private func fetchMainContentData() async {
        do {
            try await contentModel.fetchProfile(client: client,
                                                modelContext: modelContext)
        } catch let error as MainContentModel.Error {
            Logger.model.error("Failed to fetch profile: \(error)")
            lastError = error
            showError = true
            return
        } catch {
            Logger.model.error("Unhandled error encountered: \(error)")
            return
        }

        do {
            try await contentModel.fetchBikes(client: client,
                                              modelContext: modelContext)
        } catch let error as MainContentModel.Error {
            Logger.model.error("Failed to user's bikes: \(error)")
            lastError = error
            showError = true
            return
        } catch {
            Logger.model.error("Failed to fetch user's bikes with \(error)")
            return
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

        return MainContentPage()
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

        return MainContentPage()
            .environment(client)
            .modelContainer(container)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
