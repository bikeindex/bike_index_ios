//
//  BikeDetailOfflineView.swift
//  BikeIndex
//
//  Created by Jack on 5/26/25.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

//extension URL: Identifiable {
//    public var id: ObjectIdentifier {
//        self.absoluteString.hashValue
//    }
//}

/// Display the details for a bike from the local cache.
struct BikeDetailOfflineView: View {
    @Environment(Client.self) var client

    /// Query is only returns arrays and we'll pick the only element.
    @Query private var bikeQuery: [Bike]

    init(bikeIdentifier: Bike.BikeIdentifier) {
        _bikeQuery = Query(
            filter: #Predicate<Bike> { model in
                model.identifier == bikeIdentifier
            })
    }

    private var bike: Bike? {
        return bikeQuery.count == 1 ? bikeQuery.first : nil
    }

    var body: some View {
        if let bike {
            ScrollView {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        let largeImage: [URL] = [bike.largeImage]
                            .compactMap { $0 }
                        let publicImages = bike.publicImages.compactMap(URL.init(string:))
                        let allImages = largeImage + publicImages
                        let imageUrls = allImages.enumerated().map { (offset: $0, element: $1) }
                        ForEach(imageUrls, id: \.offset) { index, url in
                            CachedAsyncImage(url: url)
                        }
                    }
                }
                /*
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                        ForEach(models) { item in
                            GridRow {
                                VStack(alignment: .leading) {
                                    content(item)
                                }.frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    maxHeight: .infinity,
                                    alignment: .topLeading
                                )
                            }
                        }
                    }
                } header: {
                    Text("^[\(models.count) \(Model.displayName)](inflect: true)")
                }
                 */

                Text(bike.bikeDescription ?? "_")
                Text(bike.manufacturerName)
                Text(bike.statusString)
                Text(bike.url.absoluteString)
                Text(bike.year.debugDescription)
                Text(bike.typeOfCycle.name)
                Text(bike.frameColorPrimary.displayValue)
                Text(bike.frameColorSecondary?.displayValue ?? "secondary")
                Text(bike.frameColorTertiary?.displayValue ?? "tertiary")
                Text(bike.frameModel ?? "model")
                Text(bike.serial ?? BikeRegistration.Serial.unknown)
                Text(bike.largeImage?.absoluteString ?? "large image")
                Text(bike.publicImages.joined(separator: "\n"))
                Text(bike.stolenLocation ?? "stolen location")
                Text(bike.stolenCoordinates?.description ?? "x")
                Text(bike.dateStolen?.description ?? "x")
                Text(bike.editReportStolen?.description ?? "x")
            }
            .navigationTitle(bike.title)
        } else {
            ContentUnavailableView(
                "Bike not found",
                systemImage: "questionmark.diamond")
        }
    }

}

#Preview {
    let container = try! ModelContainer(
        for: Bike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    NavigationStack {
        BikeDetailOfflineView(bikeIdentifier: 20348)
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
