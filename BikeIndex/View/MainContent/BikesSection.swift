//
//  BikesSection.swift
//  BikeIndex
//
//  Created by Jack on 3/2/25.
//

import SwiftData
import SwiftUI

struct BikesSection: View {
    @Binding var path: NavigationPath
    private(set) var title: String
    @Query private var bikes: [Bike]

    init(path: Binding<NavigationPath>, title: String, group: Group) {
        self._path = path
        self.title = title
        _bikes = Query(filter: group.filterPredicate)
    }

    var body: some View {
        Section {
            ForEach(Array(bikes.enumerated()), id: \.element) { (index, bike) in
                ContentBikeButtonView(
                    path: $path,
                    bikeIdentifier: bike.identifier
                )
                .accessibilityIdentifier("Bike \(index + 1)")
            }
            .padding()
        } header: {
            Text(title)
                .padding([.top, .bottom], 4)
                .frame(maxWidth: .infinity)
                .font(.headline)
                .background(.ultraThinMaterial)
        }
    }
}

extension BikesSection {
    enum Group {
        case byStatus(BikeStatus)
        case byManufacturer(String)

        var filterPredicate: Predicate<Bike> {
            switch self {
            case .byStatus(let status):
                return #Predicate<Bike> { model in
                    model.statusString == status.rawValue
                }
            case .byManufacturer(let manufacturer):
                return #Predicate<Bike> { model in
                    model.manufacturerName == manufacturer
                }
            }
        }

        var displayName: String {
            switch self {
            case .byStatus(let bikeStatus):
                bikeStatus.rawValue.capitalized
            case .byManufacturer(let manufacturer):
                manufacturer
            }
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    @Previewable @State var status: BikeStatus = .withOwner
    NavigationStack {
        BikesSection(
            path: $navigationPath,
            title: "Status",
            group: .byStatus(status))
    }
}
