//
//  AttributionPlaces.swift
//  BikeIndex
//
//  Created by Jack on 10/19/25.
//

import Flow
import SwiftUI

struct AttributionPlaces: View {
    var body: some View {
        Text("Made with 💝 in:")
        HFlow(horizontalAlignment: .center, verticalAlignment: .top) {
            ForEach(ContributorPlaces.randomized) { place in
                Chip(title: place.rawValue, frame: .blue)
            }
        }
    }
}

#Preview {
    AttributionPlaces()
}
