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
    @State var url: URL?

    var body: some View {
        VStack {
            AsyncImage(url: bike.thumb) { image in
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
                WebView(url: bike.editUrl)
            }
        }
        .navigationTitle(bike.title)
    }
}


extension Bike {
    // MARK: - URLs for editing

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
