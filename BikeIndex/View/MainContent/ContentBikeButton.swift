//
//  ContentBikeButton.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct ContentBikeButtonView: View {
    @Binding var path: NavigationPath
    @Query var bikeQuery: [Bike]

    init(path: Binding<NavigationPath>, bikeIdentifier: Int) {
        self._path = path
        _bikeQuery = Query(
            filter: #Predicate<Bike> { model in
                model.identifier == bikeIdentifier
            })
    }

    var body: some View {
        if let bike = bikeQuery.first, bikeQuery.count == 1 {
            NavigationLink(value: bike.identifier) {
                VStack {
                    ZStack {
                        CachedAsyncImage(url: bike.largeImage) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "bicycle")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(
                                    minWidth: 100,
                                    maxWidth: .infinity,
                                    minHeight: 100,
                                    maxHeight: .infinity
                                )
                                .tint(Color.white)
                                .background(
                                    Color.accentColor, in: RoundedRectangle(cornerRadius: 24))

                        }
                    }
                    .frame(
                        minWidth: 100,
                        maxWidth: .infinity,
                        minHeight: 100,
                        maxHeight: .infinity
                    )
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    HStack {
                        Text(bike.displayTitle)
                    }
                }
            }
        } else {
            Text("Bike query failed, query has: \(bikeQuery.count)")
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()

    let sampleBike1 = Bike(
        identifier: 1,
        primaryColor: FrameColor.bareMetal,
        manufacturerName: "Jamis",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0,
        stolenCoordinateLongitude: 0,
        largeImage: URL(string: "https://placekitten.com/200/200"),
        url: URL(string: "about:blank").unsafelyUnwrapped,
        publicImages: [
            "https://placekitten.com/200/200"
        ]
    )

    let sampleBike2 = Bike(
        identifier: 2,
        primaryColor: FrameColor.bareMetal,
        manufacturerName: "Wide",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0,
        stolenCoordinateLongitude: 0,
        largeImage: URL(string: "https://placekitten.com/500/200"),
        url: URL(string: "about:blank").unsafelyUnwrapped,
        publicImages: [
            "https://placekitten.com/200/200"
        ]
    )

    let sampleBike3 = Bike(
        identifier: 3,
        primaryColor: FrameColor.bareMetal,
        manufacturerName: "Tall",
        typeOfCycle: BicycleType.bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0,
        stolenCoordinateLongitude: 0,
        largeImage: URL(string: "https://placekitten.com/200/500"),
        url: URL(string: "about:blank").unsafelyUnwrapped,
        publicImages: [
            "https://placekitten.com/200/200"
        ]
    )

    let sampleBike4 = Bike(
        identifier: 4,
        primaryColor: FrameColor.bareMetal,
        manufacturerName: "Empty",
        typeOfCycle: BicycleType.bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0,
        stolenCoordinateLongitude: 0,
        largeImage: nil,
        url: URL(string: "about:blank").unsafelyUnwrapped,
        publicImages: [
            "https://placekitten.com/200/200"
        ]
    )

    let samples = [sampleBike1, sampleBike2, sampleBike3, sampleBike4]
    let sampleIdentifiers = samples.map { $0.identifier }

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let mockContainer = try! ModelContainer(
        for: Bike.self,
        configurations: config
    )

    for model in samples {
        mockContainer.mainContext.insert(model)
    }
    try! mockContainer.mainContext.save()

    return ScrollView {
        ProportionalLazyVGrid {
            ForEach(sampleIdentifiers, id: \.self) {
                ContentBikeButtonView(
                    path: $navigationPath,
                    bikeIdentifier: $0)
            }
        }
    }
    .modelContainer(mockContainer)
}
