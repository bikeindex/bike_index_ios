//
//  BikesList.swift
//  BikeIndex
//
//  Created by Jack on 3/23/25.
//

import SwiftUI
import SwiftData
import SectionedQuery

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
                    // TODO: Unify BikesSection.Group and MainContentPage.ViewModel.GroupMode
                    let sectionGroup: BikesSection.Group = switch group {
                    case .byStatus: .byStatus(BikeStatus(rawValue: section.id)!)
                    case .byManufacturer: .byManufacturer(section.id)
                    }
                    BikesSection(path: $path,
                                 title: section.id,
                                 group: sectionGroup)
                }
            }
        }
    }
}
