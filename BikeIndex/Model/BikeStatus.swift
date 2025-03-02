//
//  BikeStatus.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

/// Sorted by semantics. Not alphabetical.
enum BikeStatus: String, Codable, CaseIterable, Comparable, Identifiable {
    case withOwner = "with owner"
    case found
    case stolen
    case abandoned
    case impounded
    case unregisteredParkingNotification = "unregistered parking notification"

    var id: Self { self }

    public static func < (lhs: BikeStatus, rhs: BikeStatus) -> Bool {
        let lhsValue = order[lhs.rawValue] ?? 0
        let rhsValue = order[rhs.rawValue] ?? 0
        return lhsValue < rhsValue

    }

    public static func == (lhs: BikeStatus, rhs: BikeStatus) -> Bool {
        let lhsValue = order[lhs.rawValue] ?? 0
        let rhsValue = order[rhs.rawValue] ?? 0
        return lhsValue == rhsValue
    }

    private static let order: [String: Int] = [
        BikeStatus.withOwner.rawValue: 0,
        BikeStatus.found.rawValue: 1,
        BikeStatus.stolen.rawValue: 2,
        BikeStatus.abandoned.rawValue: 3,
        BikeStatus.impounded.rawValue: 4,
        BikeStatus.unregisteredParkingNotification.rawValue: 5,
    ]

}
