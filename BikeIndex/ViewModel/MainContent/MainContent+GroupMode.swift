//
//  MainContent+GroupMode.swift
//  BikeIndex
//
//  Created by Jack on 3/22/25.
//

import SectionedQuery
import SwiftData
import SwiftUI

extension MainContentPage.ViewModel {
    enum GroupMode: String, CaseIterable, Identifiable, Equatable {
        case byStatus
        case byManufacturer

        var id: String { rawValue }

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
                SectionedQuery(
                    \Bike.statusString,
                    sort: [SortDescriptor(\Bike.statusString)])
            case .byManufacturer:
                SectionedQuery(
                    \Bike.manufacturerName,
                    sort: [SortDescriptor(\Bike.manufacturerName)])
            }
        }

        // MARK: - Persistence

        static private let persistenceKey = "groupMode_id"

        static var lastKnownGroupMode: Self {
            if let id = UserDefaults.standard.string(forKey: persistenceKey),
                let mode = Self(rawValue: id)
            {
                return mode
            } else {
                return .byStatus
            }
        }

        func persist() {
            UserDefaults.standard.set(self.id, forKey: Self.persistenceKey)
        }
    }
}
