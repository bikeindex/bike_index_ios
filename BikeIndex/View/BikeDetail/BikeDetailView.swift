//
//  BikeDetailView.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftUI
import WebKit
import WebViewKit
import SwiftData

struct BikeDetailView: View {
    @Environment(Client.self) var client

    var bike: Bike
    @State private var url: URL?

    var body: some View {
        VStack {
            AsyncImage(url: bike.largeImage) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Button {
                    url = bike.editPhoto
                } label: {
                    Label("Add a photo", systemImage: "camera.circle")
                        .labelStyle(.titleAndIcon)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: 100)

            Text("bike!")
            NavigationLink("Edit") {
                NavigableWebView(url: bike.editUrl)
                    .environment(client)
                .navigationTitle("Edit")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationTitle(bike.title)
    }
}

#Preview {
    do {
        let client = try Client()
        let filename = "SingleBikeResponse_mock"
        let container: MultipleBikeResponseContainer? = try PreviewData.load(filename: filename)
        if let container, let responseBike = container.bikes.first {
            let bike = responseBike.modelInstance()
            return NavigationStack {
                BikeDetailView(bike: bike)
                    .environment(client)
            }
        } else {
            return Text("Failed to load preview data for \(filename)")
        }
    } catch {
        return Text(error.localizedDescription)
    }
}


extension Bike {
    // MARK: - Convenience URLs for editing

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
