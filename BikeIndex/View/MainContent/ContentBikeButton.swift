//
//  ContentBikeButton.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftUI
import SwiftData

struct ContentBikeButtonView: View {
    @Binding private var path: NavigationPath
    @Query private var bikeQuery: [Bike]

    init(path: Binding<NavigationPath>, bikeIdentifier: Int) {
        self._path = path

        let predicate = #Predicate<Bike> { model in
            model.identifier == bikeIdentifier
        }

        let descriptor = FetchDescriptor<Bike>(predicate: predicate)
        _bikeQuery = Query(descriptor)
    }

    var body: some View {
        if let bike = bikeQuery.first, bikeQuery.count == 1 {
            Button(action: {
                /// NOTE: @Observable (includes @Model) instances should **NOT** be used for NavigationPath:
                /// via https://stackoverflow.com/a/75713254
                /// Use the persistent id instead
                path.append(bike.persistentModelID)
            }, label: {
                VStack {
                    ZStack {
                        AsyncImage(url: bike.largeImage) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "bicycle")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(minWidth: 100,
                                       maxWidth: .infinity,
                                       minHeight: 100,
                                       maxHeight: .infinity)
                                .tint(Color.white)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 24))

                        }
                    }
                    .frame(minWidth: 100,
                           maxWidth: .infinity,
                           minHeight: 100,
                           maxHeight: .infinity)
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    HStack {
                        Text(bike.title)
                        Text(bike.authenticatedOwner?.identifier ?? "y")
                        Text(bike.owner?.name ?? "x")
                    }
                }
            })
        } else {
            Text("Bike query failed")
        }
    }
}

/*
#Preview {
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
            "https://placekitten.com/200/200",
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
            "https://placekitten.com/200/200",
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
            "https://placekitten.com/200/200",
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
            "https://placekitten.com/200/200",
        ]
    )

    let samples = [sampleBike1, sampleBike2, sampleBike3, sampleBike4]

    ScrollView {
        ProportionalLazyVGrid {
            ForEach(samples) { bike in
                ContentBikeButtonView(path: .constant(NavigationPath()),
                                      bikeIdentifier: bike.identifier)
            }
        }
    }
}
*/
