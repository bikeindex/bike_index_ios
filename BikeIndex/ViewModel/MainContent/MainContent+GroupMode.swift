//
//  MainContent+GroupMode.swift
//  BikeIndex
//
//  Created by Jack on 3/22/25.
//

import OSLog
import SectionedQuery
import SwiftData
import SwiftUI

extension MainContentPage.ViewModel {
    enum GroupMode: String, CaseIterable, Identifiable, Equatable {
        case byStatus
        case byYear
        case byManufacturer

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .byStatus:
                "Status"
            case .byYear:
                "Year"
            case .byManufacturer:
                "Manufacturer"
            }
        }

        var keyPath: KeyPath<Bike, String> {
            switch self {
            case .byStatus:
                \Bike.statusString
            case .byYear:
                \Bike.yearString
            case .byManufacturer:
                \Bike.manufacturerName
            }
        }

        /// Query for Bikes grouped by `self`. The sections will be sorted.
        /// E.g. byManufacturer:
        ///     SortOrder.forward: Giant, Jamis, Specialized (down arrow)
        ///     SortOrder.reverse: Specialized, Jamis, Giant (up arrow)
        /// NOTE: Although the queries _could_ have different types (\Bike.year: Int?) in practice
        /// these must all use String key paths (or an enum with a String raw value).
        /// Unfortunately this requires shadowing Enum and Int fields
        /// with String fields but hopefully this improves in iOS 19.
        func sectionQuery(with sortOrder: SortOrder) -> SectionedQuery<String, Bike> {
            switch self {
            case .byStatus:
                SectionedQuery(
                    \Bike.statusString,
                    sort: [SortDescriptor(\Bike.statusString, order: sortOrder)])
            case .byYear:
                SectionedQuery(
                    \Bike.yearString,
                    // use Int sorting
                    sort: [SortDescriptor(\Bike.year, order: sortOrder)])
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
            let sortOrder_persistenceKey = "\(Self.lastKnownGroupMode.id)-\(Self.sortOrder_baseKey)"
            guard let id = UserDefaults.standard.string(forKey: sortOrder_persistenceKey) else {
                Logger.views.debug("\(#function) failed to read \(sortOrder_persistenceKey)")
                return .forward
            }

            Logger.views.debug("\(#function) found \(id) for \(sortOrder_persistenceKey)")
            switch id {
            case "reverse":
                return .reverse
            case "forward":
                return .forward
            default:
                return .forward
            }
        }

        func persist() {
            UserDefaults.standard.set(self.id, forKey: Self.groupMode_persistenceKey)
        }

        func persist(sortOrder: SortOrder) {
            let sortOrder_persistenceKey = "\(self.id)-\(Self.sortOrder_baseKey)"
            UserDefaults.standard.set(sortOrder.identifier, forKey: sortOrder_persistenceKey)
            Logger.views.debug(
                "Persisted group mode: \(self.displayName, privacy: .public), sort order: \(sortOrder.identifier, privacy: .public)"
            )
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
