//
//  BikeDetailView.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftData
import SwiftUI
import WebKit
import WebViewKit

struct BikeDetailView: View {
    @Environment(Client.self) var client

    /// Query is only returns arrays and we'll pick the only element.
    @Query private var bikeQuery: [Bike]

    @State private var url: URL

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
        print("Reconstructed URL \(reconstructedUrl)")
        _url = State(initialValue: reconstructedUrl)
    }

    private var bike: Bike? {
        print("@@ queried bike and found \(bikeQuery.count)")
        return bikeQuery.count == 1 ? bikeQuery.first : nil
    }

    var body: some View {
        let _ = Self._printChanges()
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
                .navigationTitle(bike.title)
        } else {
            // In practice this view is never displayed because SwiftData will find the Bike
            ProgressView()
                .navigationTitle("Loading")
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Bike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    NavigationStack {
        BikeDetailView(bikeIdentifier: 20348, host: URL(stringLiteral: "https://bikeindex.org"))
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
