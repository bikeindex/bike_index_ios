//
//  BikesStatusSection.swift
//  BikeIndex
//
//  Created by Jack on 3/2/25.
//

import SwiftData
import SwiftUI

struct BikesStatusSection: View {
    @Binding var path: NavigationPath
    private(set) var status: BikeStatus
    @Query private var bikes: [Bike]

    init(path: Binding<NavigationPath>, status paramStatus: BikeStatus) {
        self._path = path
        self.status = paramStatus
        _bikes = Query(filter: #Predicate<Bike> { model in
            model.statusString == paramStatus.rawValue
        })
    }

    var body: some View {
        Section(status.rawValue.uppercased()) {
            ForEach(Array(bikes.enumerated()), id: \.element) { (index, bike) in
                ContentBikeButtonView(
                    path: $path,
                    bikeIdentifier: bike.identifier
                )
                .accessibilityIdentifier("Bike \(index + 1)")
            }
            .padding()
        }
        .navigationDestination(for: PersistentIdentifier.self) { identifier in
            if let bike = bikes.first(where: { $0.persistentModelID == identifier }) {
                // TODO: This needs to be at the NavigationStack root level
                BikeDetailView(bike: bike)
            }
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    NavigationStack {
        BikesStatusSection(path: $navigationPath,
                           status: .withOwner)
    }
}
