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

    // Control the navigation hierarchy for all views after this one
    @State var path = NavigationPath()

    // Data handling and error handling
    var contentModel = ViewModel()
    @State var lastError: ViewModel.Error?
    @State var showError: Bool = false

    @SectionedQuery(
        \Bike.statusString,
        sort: [SortDescriptor(\.statusString)])
    private var bikesByStatus: SectionedResults<String, Bike>

    var body: some View {
        NavigationStack(path: $path) {
            @Bindable var deeplinkManager = client.deeplinkManager
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in
                        ContentButtonView(
                            path: $path,
                            item: menuItem)
                    }
                }

                if bikesByStatus.isEmpty {
                    ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle")
                        .padding()
                } else {
                    ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                        ForEach(bikesByStatus) { section in
                            if let status = BikeStatus(rawValue: section.id) {
                                BikesStatusSection(
                                    path: $path,
                                    status: status)
                            }
                        }
                    }
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
                case .help:
                    NavigableWebView(
                        constantLink: .help,
                        host: client.configuration.host
                    )
                    .environment(client)
                case .registerBike:
                    RegisterBikeView(path: $path, mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(path: $path, mode: .myStolenBike)
                case .searchBikes:
                    SearchBikesView()
                        .environment(client)
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
            .sheet(item: $deeplinkManager.scannedBike, content: { scan in
                let viewModel = ScannedBikePage.ViewModel(
                    scan: scan,
                    path: path,
                    dismiss: {
                        deeplinkManager.scannedBike = nil
                    })
                ScannedBikePage(viewModel: viewModel)
                    .onDisappear {
                        if let exitPath = viewModel.onDisappear {
                            path.append(exitPath)
                        }
                    }
            })
            .alert(isPresented: $showError, error: lastError) {
                Text("Error occurred")
            }
            .onAppear {
                Logger.views.debug("Starting main content page with deeplink scanned bike \(String(describing: deeplinkManager.scannedBike))")
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
    private func fetchMainContentData() async {
        do {
            try await contentModel.fetchProfile(
                client: client,
                modelContext: modelContext)
        } catch {
            Logger.model.error("Failed to fetch profile: \(error)")
            lastError = error
            showError = true
            return
        }

        do {
            try await contentModel.fetchBikes(
                client: client,
                modelContext: modelContext)
        } catch {
            Logger.model.error("Failed to user's bikes: \(error)")
            lastError = error
            showError = true
            return
        }
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

                for (index, status) in statuses.enumerated() {
                    let output = try JSONDecoder().decode(BikeResponse.self, from: rawJsonData)
                    let bike = output.modelInstance()
                    // Mock one of each status
                    // but separate the identifiers
                    bike.identifier = index
                    bike.update(keyPath: \.status, to: status)
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

                for (index, status) in BikeStatus.allCases.enumerated() {
                    let bike = output.modelInstance()

                    // Mock one of each status
                    // but separate the identifiers
                    bike.identifier = index
                    bike.update(keyPath: \.status, to: status)
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
