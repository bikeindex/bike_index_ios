//
//  StolenBikeDetailsView.swift
//  BikeIndex
//
//  Created by Jack on 6/16/25.
//

import MapKit
import SwiftUI

struct StolenBikeDetailsView: View {
    let bike: Bike

    var body: some View {
        Text(bike.stolenLocation ?? "stolen location")
        Text(bike.stolenCoordinates?.description ?? "x")
        Text(bike.dateStolen?.description ?? "x")
        Text(bike.editReportStolen?.description ?? "x")

        if let coordinates = bike.stolenCoordinates {
            Map {
                Annotation(
                    bike.stolenLocation ?? "Location",
                    coordinate: coordinates.coordinate
                ) {
                    Text("Here")
                }
            }
            .frame(minHeight: 250)
        } else {
            Text("No coordinates to display map")
        }
    }
}

#Preview {
    @Previewable let bike = Bike.init(
        identifier: 1_234_567_890,
        primaryColor: .blue,
        secondaryColor: .bareMetal,
        tertiaryColor: .covered,
        manufacturerName: "",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0.0,
        stolenCoordinateLongitude: 0.0,
        url: URL(stringLiteral: "about:blank"),
        publicImages: [],
        createdAt: .distantPast,
        updatedAt: .now)
    StolenBikeDetailsView(bike: bike)
}
