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

/// Main page of the app to display all navigation options and Bikes.
struct MainContentPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    /// ViewModel for state management.
    /// Forwards dynamic query changes to ``BikesGridContainerView`` to support dynamic grouping selection.
    @State private var viewModel = ViewModel()

    /// Binds to the shared App Intent navigation state to handle sheet presentation.
    @Bindable(AppIntentNavigationManager.shared) var appIntentNavManager

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            @Bindable var deeplinkManager = client.deeplinkManager
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in
                        ContentButtonView(
                            path: $viewModel.path,
                            item: menuItem)
                    }
                }

                BikesGridContainerView(
                    path: $viewModel.path,
                    fetching: $viewModel.fetching,
                    sectionGroup: viewModel.groupMode,
                    sectionSortOrder: viewModel.sortOrder)
            }
            .toolbar {
                MainToolbar(
                    path: $viewModel.path,
                    loading: $viewModel.fetching,
                    groupMode: $viewModel.groupMode,
                    sortOrder: $viewModel.sortOrder,
                    displayRecentlyScannedStickers: $viewModel.displayRecentlyScannedStickers)
            }
            .navigationTitle("Bike Index")
            .navigationDestination(for: MainContent.self) { selection in
                switch selection {
                case .settings:
                    SettingsPage(path: $viewModel.path)
                        .accessibilityIdentifier("Settings")
                case .help:
                    NavigableWebView(
                        constantLink: .help,
                        host: client.configuration.host
                    )
                    .environment(client)
                case .registerBike:
                    RegisterBikeView(path: $viewModel.path, mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(path: $viewModel.path, mode: .myStolenBike)
                case .searchBikes:
                    SearchBikesView()
                        .environment(client)
                }
            }
            .navigationDestination(for: Bike.BikeIdentifier.self) { identifier in
                /// ``ContentBikeButtonView`` uses `NavigationLink`s to ``Bike/identifier``.
                BikeDetailWebView(
                    bikeIdentifier: identifier,
                    host: client.configuration.host)
            }
            .sheet(
                item: $deeplinkManager.scannedBike,
                content: { scan in
                    // Open the new sticker
                    let viewModel = ScannedBikePage.ViewModel(
                        scan: scan,
                        path: viewModel.path,
                        dismiss: {
                            deeplinkManager.scannedBike = nil
                        })
                    ScannedBikePage(viewModel: viewModel)
                        .onDisappear {
                            if let exitPath = viewModel.onDisappear {
                                viewModel.path.append(exitPath)
                            }
                        }
                }
            )
            .sheet(
                item: $appIntentNavManager.presentedItem,
                content: { presentedItem in
                    // Opens directly into the BikeDetailOfflineView for the bike selected via App Intents
                    NavigationStack {
                        BikeDetailOfflineView(bikeIdentifier: presentedItem.bikeIdentifier)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDragIndicator(.visible)
                }
            )
            .fullScreenCover(
                isPresented: $viewModel.displayRecentlyScannedStickers,
                content: {
                    RecentlyScannedStickersView(display: $viewModel.displayRecentlyScannedStickers)
                        .environment(client)
                }
            )
            // empty action block to rely on default Button("OK") behavior
            .alert(isPresented: $viewModel.showError, error: viewModel.lastError) {}
            .onAppear {
                Logger.views.debug(
                    "Starting main content page with deeplink scanned bike \(String(describing: deeplinkManager.scannedBike))"
                )
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
                let years: [Int?] = [2025, 2020, nil]
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
                    bike.update(keyPath: \.year, to: years[index])
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
                let years: [Int?] = [2025, 2024, 2020, 2015, 2014, nil]

                for (index, status) in BikeStatus.allCases.enumerated() {
                    let bike = output.modelInstance()

                    // Mock one of each status
                    // but separate the identifiers
                    bike.identifier = index
                    bike.update(keyPath: \.status, to: status)
                    bike.update(keyPath: \.year, to: years[index])
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
