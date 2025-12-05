//
//  BikeV1Schema.swift
//  BikeIndex
//
//  Created by Jack on 10/4/25.
//

import Foundation
import SwiftData

/// Models defined in extensions
/// "V1" suffix does NOT relate to the app version
/// ``BikeSchemaV1/versionIdentifier`` DOES relate to the app version
enum BikeSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 6, 0)

    static var models: [any PersistentModel.Type] {
        [BikeSchemaV1.Bike.self, User.self, AuthenticatedUser.self, ScannedBike.self, AutocompleteManufacturer.self]
    }
}

enum BikeSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 6, 1)

    static var models: [any PersistentModel.Type] {
        [BikeSchemaV2.Bike.self]
    }
}
