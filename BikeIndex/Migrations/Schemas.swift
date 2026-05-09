//
//  BikeSchemaV1.swift
//  BikeIndex
//
//  Created by Jack on 5/3/26.
//

import Foundation
import SwiftData

/// Models are defined in extensions and typealiases
/// A) "1" suffix does NOT relate to the app version
/// B) ``BikeSchemaV1/versionIdentifier`` DOES relate to the app version
enum Schema1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 6, 2)

    static var models: [any PersistentModel.Type] {
        [
            Schema1.Bike.self, User.self, AuthenticatedUser.self, ScannedBike.self,
            AutocompleteManufacturer.self,
        ]
    }
}

enum Schema2: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 6, 3)

    static var models: [any PersistentModel.Type] {
        [
            Schema2.Bike.self,
            User.self,
            AuthenticatedUser.self,
            ScannedBike.self,
            AutocompleteManufacturer.self,
            FullPublicImage.self,
            Component.self,
            StolenBikeRecord.self,
        ]
    }
}
