//
//  BikeDetailWebView.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import Network
import SwiftData
import SwiftUI
import WebKit
import WebViewKit

/// Display the details for a bike primarily from the network.
struct BikeDetailWebView: View {
    @Environment(Client.self) var client
    @Environment(\.modelContext) private var modelContext

    /// Query is only returns arrays and we'll pick the only element.
    @Query private var bikeQuery: [Bike]

    @State private var url: URL
    // TODO: Move NetworkStatusChecker to ViewModel
    @State private var checker: NetworkStatusChecker = .shared

    @State private var viewModel = ViewModel()

    /// Initialize with a BikeIdentifier and base URL. The base URL must be retrieved before Client is available.
    /// With these inputs the Bike's canonical URL can be constructed and displayed in the NavigableWebView.
    /// ``NavigableWebView`` requires that `@State var url: URL` be non-optional and start at a valid URL (don't start at about:blank because the change won't get picked up from a @Query load event) so we hack this together with `host+"/bikes/"+bikeIdentifier`
    /// - Parameters:
    ///   - bikeIdentifier: The Rails BikeIndex record identifier.
    ///   - host: Value from ``Client/configuration`` that must be passed directly because Environment Client is not available at init() time.
    init(bikeIdentifier: Bike.BikeIdentifier, host: URL) {
        _bikeQuery = Query(
            filter: #Predicate<Bike> { model in
                model.identifier == bikeIdentifier
            })

        let reconstructedUrl = host.appending(path: "bikes/\(bikeIdentifier)")
        _url = State(initialValue: reconstructedUrl)
    }

    private var bike: Bike? {
        return bikeQuery.count == 1 ? bikeQuery.first : nil
    }

    var body: some View {
        if let bike {
            NavigableWebView(url: $url)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit", systemImage: "pencil") {
                            if let editUrl = bike.editUrl {
                                url = editUrl
                            }
                        }
                    }
                })
                .navigationTitle(bike.displayTitle)
                .sheet(isPresented: $checker.presentOfflineMode) {
                    NavigationStack {
                        BikeDetailOfflineView(bikeIdentifier: bike.identifier)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDragIndicator(.visible)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .task {
                    await viewModel.fetchFullBikeDetails(
                        client: client, modelContext: modelContext, bike.identifier)
                }
        } else {
            // In practice this view is never displayed because SwiftData will find the Bike
            ProgressView()
                .toolbar(content: {
                    statusToolbar
                })
                .navigationTitle("Loading")
        }
    }

    var statusToolbar: some ToolbarContent {
        ToolbarItem(placement: .status) {
            Button(checker.status.displayTitle) {
                checker.presentOfflineMode.toggle()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Bike.self, FullPublicImage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    NavigationStack {
        BikeDetailWebView(bikeIdentifier: 20348, host: URL(stringLiteral: "https://bikeindex.org"))
            .environment(try! Client())
            .modelContainer(container)
    }
    .onAppear {
        do {
            let mockResponse = try PreviewData.loadMultipleBikeResponseMock()
            print("Found mock response \(mockResponse)")
            if let responseBike = mockResponse.bikes.first {
                let bike = responseBike.modelInstance()
                container.mainContext.insert(bike)
                try container.mainContext.save()
            }
        } catch {
            print("Failed to render \(error.localizedDescription)")
        }
    }
}

extension Bike {
    // MARK: - Convenience URLs for future granular editing

    @Transient var editUrl: URL? {
        url.appending(path: "edit/bike_details")
    }

    @Transient var editPhoto: URL? {
        url.appending(path: "edit/photos")
    }

    @Transient var editDrivetrain: URL? {
        url.appending(path: "edit/drivetrain")
    }

    @Transient var editAccessories: URL? {
        url.appending(path: "edit/accessories")
    }

    @Transient var editOwnership: URL? {
        url.appending(path: "edit/ownership")
    }

    @Transient var editGroups: URL? {
        url.appending(path: "edit/groups")
    }

    @Transient var editRemove: URL? {
        url.appending(path: "edit/remove")
    }

    @Transient var editVersions: URL? {
        url.appending(path: "edit/versions")
    }

    @Transient var editReportStolen: URL? {
        url.appending(path: "edit/report_stolen")
    }
}
