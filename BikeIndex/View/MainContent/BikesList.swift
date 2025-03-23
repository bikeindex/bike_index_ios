//
//  BikesList.swift
//  BikeIndex
//
//  Created by Jack on 3/23/25.
//

import SwiftUI
import SwiftData
import SectionedQuery

/// Display multiple sections of bikes together
struct BikesList: View {
    @Binding var path: NavigationPath

    @SectionedQuery(\Bike.statusString)
    var bikes: SectionedResults<String, Bike>

    var group: MainContentPage.ViewModel.GroupMode

    init(path: Binding<NavigationPath>, group: MainContentPage.ViewModel.GroupMode) {
        _path = path
        self.group = group
        _bikes = group.sectionQuery
    }

    var body: some View {
        let _ = Self._printChanges()
        if bikes.isEmpty {
            ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle")
                .padding()
        } else {
            ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                ForEach(bikes) { section in
                    /// Map the broad group (byStatus, byManufacturer)
                    /// to a _specific_ status or manufacturer to display in _this_ section.
                    /// Use an optional SectionValue because the ``BikeStatus`` has to map
                    /// from a string (we can search on ``Bike/statusString`` but **not** Bike.status
                    /// so there could be a BikeStatus(rawValue:) initializer that fails.
                    let section: BikesSection.SectionValue? = switch group {
                    case .byStatus:
                        if let status = BikeStatus(rawValue: section.id) {
                            BikesSection.SectionValue.byStatus(status)
                        } else {
                            Optional<BikesSection.SectionValue>(nil)
                        }
                    case .byManufacturer: .byManufacturer(section.id)
                    }
                    if let section {
                        BikesSection(path: $path,
                                     section: section)
                    } else {
                        Text("Error rendering section")
                    }
                }
            }
        }
    }
}
