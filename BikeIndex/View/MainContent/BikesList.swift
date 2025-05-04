//
//  BikesList.swift
//  BikeIndex
//
//  Created by Jack on 3/23/25.
//

import SectionedQuery
import SwiftData
import SwiftUI

/// Display multiple sections of bikes together
struct BikesList: View {
    @Binding var path: NavigationPath
    @Binding var fetching: Bool

    @SectionedQuery
    var bikes: SectionedResults<String, Bike>

    var group: MainContentPage.ViewModel.GroupMode
    /// Sort order applies to the sections, not the bikes in each section.
    var sortOrder: SortOrder

    init(
        path: Binding<NavigationPath>, fetching: Binding<Bool>,
        group: MainContentPage.ViewModel.GroupMode,
        sortOrder: SortOrder
    ) {
        _path = path
        _fetching = fetching
        self.group = group
        self.sortOrder = sortOrder

        _bikes = group.sectionQuery(with: sortOrder)
    }

    var body: some View {
        if fetching {
            ContentUnavailableView("Fetching bikes…", systemImage: "bicycle.circle")
                .padding()
        } else if bikes.isEmpty {
            ContentUnavailableView("No bikes registered", systemImage: "bicycle.circle.fill")
                .padding()
        } else {
            ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                ForEach(bikes) { section in
                    /// Map the broad group (byStatus, byManufacturer)
                    /// to a _specific_ status or manufacturer to display in _this_ section.
                    /// Use an optional SectionValue because the ``BikeStatus`` has to map
                    /// from a string (we can search on ``Bike/statusString`` but **not** Bike.status
                    /// so there could be a BikeStatus(rawValue:) initializer that fails.
                    let section: BikesSection.SectionValue? =
                        switch group {
                        case .byStatus:
                            if let status = BikeStatus(rawValue: section.id) {
                                BikesSection.SectionValue.byStatus(status)
                            } else {
                                BikesSection.SectionValue?(nil)
                            }
                        case .byYear: .byYear(section.id)
                        case .byManufacturer: .byManufacturer(section.id)
                        }
                    if let section {
                        BikesSection(
                            path: $path,
                            section: section)
                    } else {
                        Text("Error rendering section")
                    }
                }
            }
        }
    }
}
