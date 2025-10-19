//
//  AttributionPlaces.swift
//  BikeIndex
//
//  Created by Jack on 10/19/25.
//

import Flow
import SwiftUI

/// List the city/place of each contributor with a background color Chip
struct AttributionPlaces: View {
    var body: some View {
        Text("Made with 💝 in:")
        HFlow(horizontalAlignment: .center, verticalAlignment: .top) {
            ForEach(contributorPlacesByChipColor, id: \.0) { place, color in
                Chip(title: place.rawValue, color: color)
            }
        }
    }

    /// If there are ever more contributors than FrameColors/Chip-colors, then repeat the FrameColors to still display
    var contributorPlacesByChipColor: [(ContributorPlaces, FrameColor)] {
        let places = ContributorPlaces.randomized
        let count = Int(round(Double(places.count) / Double(FrameColor.allCases.count)))
        let backgroundColors = Array(
            repeating: FrameColor.allCases, count: count)
            .flatMap { $0 }

        return Array(zip(places, backgroundColors))
    }
}

#Preview {
    AttributionPlaces()
}
