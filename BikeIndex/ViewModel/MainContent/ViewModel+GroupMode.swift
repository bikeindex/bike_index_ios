//
//  MainContentPage+ViewModel+GroupMode.swift
//  BikeIndex
//
//  Created by Jack on 3/22/25.
//

import SwiftUI
import SwiftData
import SectionedQuery

extension MainContentPage.ViewModel {
    enum GroupMode: CaseIterable, Identifiable, Equatable {
        case byStatus
        case byManufacturer

        var id: Self { self }

        var displayName: String {
            switch self {
            case .byStatus:
                return "Status"
            case .byManufacturer:
                return "Manufacturer"
            }
        }

        var keyPath: KeyPath<Bike, String> {
            switch self {
            case .byStatus:
                \Bike.statusString
            case .byManufacturer:
                \Bike.manufacturerName
            }
        }

        var sectionQuery: SectionedQuery<String, Bike> {
            switch self {
            case .byStatus:
                SectionedQuery(\Bike.statusString,
                              sort: [SortDescriptor(\Bike.statusString)])
            case .byManufacturer:
                SectionedQuery(\Bike.manufacturerName,
                              sort: [SortDescriptor(\Bike.manufacturerName)])
            }
        }
    }
}
