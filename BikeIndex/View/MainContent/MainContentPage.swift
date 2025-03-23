//
//  MainContentPage.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SectionedQuery
import SwiftData
import SwiftUI

struct MainContentPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    /// ViewModel for state management.
    /// Forwards dynamic query changes to ``BikesList`` to support dynamic grouping selection.
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in
                        ContentButtonView(
                            path: $viewModel.path,
                            item: menuItem)
                    }
                }

                BikesList(path: $viewModel.path,
                          group: viewModel.groupMode)
            }
            .toolbar {
                MainToolbar(
                    path: $viewModel.path,
                    loading: $viewModel.fetching,
                    groupMode: $viewModel.groupMode)
            }
            .navigationTitle("Bike Index")
            .navigationDestination(for: MainContent.self) { selection in
                switch selection {
                case .settings:
                    SettingsPage(path: $viewModel.path)
                        .accessibilityIdentifier("Settings")
                case .registerBike:
                    RegisterBikeView(mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(mode: .myStolenBike)
                case .searchBikes:
                    SearchBikesView()
                }
            }
            .navigationDestination(for: PersistentIdentifier.self) { identifier in
                // TODO: Change BikeDetailView to just read a PersistentIdentifier, consider strongly typing Bike.persistentModelID
//                ForEach(bikes) { section in
//                    if let bike = section.elements.first(where: {
//                        $0.persistentModelID == identifier
//                    }) {
//                        BikeDetailView(bike: bike)
//                    }
//                }
            }
            .alert(isPresented: $viewModel.showError, error: viewModel.lastError) {
                Text("Okay")
            }
        }
        .task {
            /// Comment this out to test ``MainContentPage/ViewModel/fetching`` display
            await viewModel.fetchMainContentData(
                client: client,
                modelContext: modelContext)

        }
    }
}

// MARK: - Previews

// MARK: Empty Data Preview
#Preview("Empty data") {
    @Previewable let client = try! Client()

    @Previewable let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    MainContentPage()
        .environment(client)
        .modelContainer(container)
}

// MARK: Bikes by status (withOwner)
#Preview("Bikes by status (withOwner)") {
    let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    MainContentPage()
        .environment(try! Client())
        .modelContainer(container)
        .onAppear {
            do {
                let rawJsonData = MockData.sampleBikeJson.data(using: .utf8)!
                let statuses: [BikeStatus] = Array(repeating: .withOwner, count: 3)
                let manufacturers = [
                    "Giant", "Specialized", "Jamis", "Giant", "Specialized", "Jamis",
                ]

                for (index, status) in statuses.enumerated() {
                    let output = try JSONDecoder().decode(BikeResponse.self, from: rawJsonData)
                    let bike = output.modelInstance()
                    // Mock one of each status
                    // but separate the identifiers
                    bike.identifier = index
                    bike.update(keyPath: \.status, to: status)
                    bike.update(keyPath: \.manufacturerName, to: manufacturers[index])
                    print(
                        "Pre-insert bike \(bike.identifier) with \(bike.status.rawValue) / status string = \(bike.statusString)"
                    )

                    container.mainContext.insert(bike)
                }
                try? container.mainContext.save()
            } catch {
                print("Encountered error \(error)")
            }
        }
}

// MARK: Bikes by status (all)
#Preview("Bikes by status (all)") {
    let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    MainContentPage()
        .environment(try! Client())
        .modelContainer(container)
        .onAppear {
            do {
                let rawJsonData = MockData.sampleBikeJson.data(using: .utf8)!
                let output = try JSONDecoder().decode(BikeResponse.self, from: rawJsonData)
                let manufacturers = [
                    "Giant", "Specialized", "Jamis", "Giant", "Specialized", "Jamis",
                ]

                for (index, status) in BikeStatus.allCases.enumerated() {
                    let bike = output.modelInstance()

                    // Mock one of each status
                    // but separate the identifiers
                    bike.identifier = index
                    bike.update(keyPath: \.status, to: status)
                    bike.update(keyPath: \.manufacturerName, to: manufacturers[index])
                    print(
                        "Pre-insert bike \(bike.identifier) with \(bike.status.rawValue) / status string = \(bike.statusString)"
                    )

                    container.mainContext.insert(bike)
                }
                try? container.mainContext.save()
            } catch {
                print("Encountered error \(error)")
            }
        }
}
