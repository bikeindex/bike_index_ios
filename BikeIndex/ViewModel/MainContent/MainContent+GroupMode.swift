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

        /// Query for Bikes grouped by `self`: either byStatus or byManufacturer
        /// The sections will be sorted.
        /// E.g. SortOrder.forward: Giant, Jamis, Specialized (down arrow)
        ///      SortOrder.reverse: Specialized, Jamis, Giant (up arrow)
        func sectionQuery(with sortOrder: SortOrder) -> SectionedQuery<String, Bike> {
            switch self {
            case .byStatus:
                SectionedQuery(
                    \Bike.statusString,
                    sort: [SortDescriptor(\Bike.statusString, order: sortOrder)])
            case .byManufacturer:
                SectionedQuery(
                    \Bike.manufacturerName,
                    sort: [SortDescriptor(\Bike.manufacturerName, order: sortOrder)])
            }
        }

        // MARK: - Persistence for GroupMode and SortOrder

        static private let groupMode_persistenceKey = "groupMode_id"
        static private let sortOrder_baseKey = "sortOrder_id"

        static var lastKnownGroupMode: Self {
            if let id = UserDefaults.standard.string(forKey: groupMode_persistenceKey),
                let mode = Self(rawValue: id)
            {
                return mode
            } else {
                return .byStatus
            }
        }

        static var lastKnownSortOrder: SortOrder {
            let sortOrder_persistenceKey = "\(Self.lastKnownGroupMode.id)_\(Self.sortOrder_baseKey)"
            guard let id = UserDefaults.standard.string(forKey: sortOrder_persistenceKey) else {
                return .forward
            }

            switch id {
            case "reverse":
                return .reverse
            case "forward":
                return .forward
            default:
                return .forward
            }
        }

        func persist(with sortOrder: SortOrder) {
            UserDefaults.standard.set(self.id, forKey: Self.groupMode_persistenceKey)
            let sortOrder_persistenceKey = "\(self.id)_\(Self.sortOrder_baseKey)"
            UserDefaults.standard.set(sortOrder.displayName, forKey: sortOrder_persistenceKey)
        }
    }
}

extension SortOrder {
    var identifier: String {
        switch self {
        case .forward:
            "forward"
        case .reverse:
            "reverse"
        }
    }

    var displayName: String {
        switch self {
        case .forward:
            return "Ascending"
        case .reverse:
            return "Descending"
        }
    }

    func toggle() -> SortOrder {
        if self == .forward {
            .reverse
        } else {
            .forward
        }
    }
}
