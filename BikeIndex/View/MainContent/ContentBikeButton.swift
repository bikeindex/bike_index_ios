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
                    if let hero = URL(string: bike.publicImages.first ?? "https://placekitten.com/200/200") {
                        AsyncImage(url: hero) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            EmptyView()
                        }
                    }
                    Text("\(String(bike.year ?? 0)) \(bike.manufacturerName)")
                        .font(.largeTitle)
                }
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24))

                Text("\(String(bike.year ?? 0)) \(bike.manufacturerName)")
            }
        })
    }
}

#Preview {
    let sampleBike = Bike(identifier: 1,
                          primaryColor: FrameColor.bareMetal,
                          manufacturerName: "Jamis",
                          typeOfCycle: BicycleType.bike,
                          status: .withOwner,
                          stolenCoordinateLatitude: 0,
                          stolenCoordinateLongitude: 0,
                          url: URL(string: "about:blank").unsafelyUnwrapped,
                          publicImages: [
                            "https://placekitten.com/200/200",
                          ])

    return ContentBikeButtonView(path: .constant(NavigationPath()),
                                 bike: sampleBike)
}
