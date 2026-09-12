//
//  BikesGridContainerView.swift
//  BikeIndex
//
//  Created by Jack on 3/23/25.
//

import HoneybadgerSwift
import SectionedQuery
import SwiftData
import SwiftUI

/// Display multiple sections of bikes together
struct BikesGridContainerView: View {
    @Binding var path: NavigationPath
    @Binding var fetching: Bool

    /// The current grouping mode that should be used to section bikes. Ex: byStatus.
    /// Primary key and combines with sort order for section titles.
    private var group: MainContentPage.ViewModel.GroupMode
    /// Sort order applies to the sections, not the bikes in each section.
    /// See ``MainContentPage/ViewModel/GroupMode/sectionQuery(with:)`` to sort the bikes within a section.
    private var sectionSortOrder: SortOrder

    /// "Output": bikes grouped by a particular section suitable for ordered display.
    @SectionedQuery
    private var sections: SectionedResults<String, Bike>

    init(
        path: Binding<NavigationPath>,
        fetching: Binding<Bool>,
        sectionGroup group: MainContentPage.ViewModel.GroupMode,
        sectionSortOrder: SortOrder,
        authenticatedUsers: [AuthenticatedUser]
    ) {
        _path = path
        _fetching = fetching
        self.group = group
        self.sectionSortOrder = sectionSortOrder

        let authenticatedUserEmail: String
        if authenticatedUsers.count == 1, let user = authenticatedUsers.first?.user {
            authenticatedUserEmail = user.email
        } else {
            let error = "Found more than one active authenticated user"
            Honeybadger.notify(errorString: error)
            authenticatedUserEmail = ""
        }

        _sections = group.sectionQuery(
            with: sectionSortOrder, authenticatedUserEmail: authenticatedUserEmail)
    }

    var body: some View {
        if fetching {
            ContentUnavailableView("Fetching bikes…", systemImage: "bicycle.circle")
                .padding()
        } else if sections.isEmpty {
            ContentUnavailableView {
                Label("No bikes registered", systemImage: "bicycle.circle")
            } actions: {
                Button("Register your first bike today") {
                    path.append(MainContent.registerBike)
                }
            }
            .padding()
        } else {
            ProportionalLazyVGrid(pinnedViews: [.sectionHeaders]) {
                ForEach(sections) { section in
                    BikesGridSectionView(
                        path: $path,
                        section: section.id,
                        bikes: section.elements)  // aka section.bikes
                }
            }
        }
    }
}
