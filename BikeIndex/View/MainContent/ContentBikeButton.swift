//
//  ContentBikeButton.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftUI

struct ContentBikeButtonView: View {
    @Binding var path: NavigationPath
    var bike: Bike

    var body: some View {
        Button(action: {
            path.append(bike)
        }, label: {
            VStack {
                ZStack {
                    AsyncImage(url: bike.largeImage) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "bicycle.circle.fill")
                            .resizable()
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                Text(bike.title)
            }
        })
    }
}

#Preview {
    let sampleBike1 = Bike(identifier: 1,
                          primaryColor: FrameColor.bareMetal,
                          manufacturerName: "Jamis",
                          typeOfCycle: BicycleType.bike,
                          status: .withOwner,
                          stolenCoordinateLatitude: 0,
                          stolenCoordinateLongitude: 0,
                          largeImage: URL(string: "https://placekitten.com/200/200"),
                          url: URL(string: "about:blank").unsafelyUnwrapped,
                          publicImages: [
                            "https://placekitten.com/200/200",
                          ])

    let sampleBike2 = Bike(identifier: 2,
                          primaryColor: FrameColor.bareMetal,
                          manufacturerName: "Wide",
                          typeOfCycle: BicycleType.bike,
                          status: .withOwner,
                          stolenCoordinateLatitude: 0,
                          stolenCoordinateLongitude: 0,
                          largeImage: URL(string: "https://placekitten.com/500/200"),
                          url: URL(string: "about:blank").unsafelyUnwrapped,
                          publicImages: [
                            "https://placekitten.com/200/200",
                          ])

    let sampleBike3 = Bike(identifier: 3,
                          primaryColor: FrameColor.bareMetal,
                          manufacturerName: "Tall",
                          typeOfCycle: BicycleType.bike,
                          status: .withOwner,
                          stolenCoordinateLatitude: 0,
                          stolenCoordinateLongitude: 0,
                          largeImage: URL(string: "https://placekitten.com/200/500"),
                          url: URL(string: "about:blank").unsafelyUnwrapped,
                          publicImages: [
                            "https://placekitten.com/200/200",
                          ])

    let sampleBike4 = Bike(identifier: 4,
                          primaryColor: FrameColor.bareMetal,
                          manufacturerName: "Empty",
                          typeOfCycle: BicycleType.bike,
                          status: .withOwner,
                          stolenCoordinateLatitude: 0,
                          stolenCoordinateLongitude: 0,
                          largeImage: nil,
                          url: URL(string: "about:blank").unsafelyUnwrapped,
                          publicImages: [
                            "https://placekitten.com/200/200",
                          ])

    let samples = [sampleBike1, sampleBike2, sampleBike3, sampleBike4]

    return ScrollView {
        ProportionalLazyVGrid {
            ForEach(samples) { bike in
                ContentBikeButtonView(path: .constant(NavigationPath()),
                                      bike: bike)
            }
        }
    }
}
