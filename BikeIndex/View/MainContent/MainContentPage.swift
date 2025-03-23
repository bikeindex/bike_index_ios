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

    // ViewModel for state management (but not query management)
    @State var viewModel = ViewModel()

    @SectionedQuery(
        \Bike.statusString,
        sort: [SortDescriptor(\.statusString)])
    private var bikesByStatus: SectionedResults<String, Bike>

    @SectionedQuery(
        \Bike.manufacturerName,
        sort: [SortDescriptor(\.manufacturerName)])
    private var bikesByManufacturer: SectionedResults<String, Bike>

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

                // Loading state views are handled in an overlay to apply everywhere
                // TODO: Replace duplicated `SectionedQuery` with a mutable sort parameter
                switch viewModel.groupMode {
                case .byStatus:
                    if bikesByStatus.isEmpty {
                        ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle")
                            .padding()
                    } else {
                        ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                            ForEach(bikesByStatus) { section in
                                if let status = BikeStatus(rawValue: section.id) {
                                    BikesSection(
                                        path: $viewModel.path,
                                        title: status.rawValue.capitalized,
                                        group: .byStatus(status))
                                }
                            }
                        }
                    }
                case .byManufacturer:
                    if bikesByManufacturer.isEmpty {
                        ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle")
                            .padding()
                    } else {
                        ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                            ForEach(bikesByManufacturer) { section in
                                BikesSection(
                                    path: $viewModel.path,
                                    title: section.id,
                                    group: .byManufacturer(section.id))
                            }
                        }
                    }
                }
            }
            .toolbar {
                MainToolbar(
                    path: $viewModel.path,
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
                ForEach(bikesByStatus) { section in
                    if let bike = section.elements.first(where: {
                        $0.persistentModelID == identifier
                    }) {
                        BikeDetailView(bike: bike)
                    }
                }
            }
            .alert(isPresented: $viewModel.showError, error: viewModel.lastError) {
                Text("Okay")
            }
        }
        .overlay {
            if viewModel.fetching {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetchMainContentData(
                client: client,
                modelContext: modelContext)
        }
    }
}

extension MainContentPage {
    // Initializer for previews
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Previews

// MARK: Empty Data Preview
#Preview("Empty data") {
    do {
        let client = try Client()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
            configurations: config)

        return MainContentPage()
            .environment(client)
            .modelContainer(container)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
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

// MARK: Fetching bikes by status
#Preview("Fetching bikes by status") {
    @Previewable @State var viewModel = MainContentPage.ViewModel(fetching: true)
    @Previewable let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    MainContentPage(viewModel: viewModel)
        .environment(try! Client())
        .modelContainer(container)
        .onAppear {
            print("onAppear.ViewModel = \(viewModel)")

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

                print("ViewModel.fetching = \(viewModel.fetching)")
            } catch {
                print("Encountered error \(error)")
            }
        }
}
