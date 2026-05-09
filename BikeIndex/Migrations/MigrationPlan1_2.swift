//
//  MigrationPlan1_2.swift
//  BikeIndex
//
//  Created by Jack on 5/4/26.
//

import SwiftData

enum MigrationPlan_1_2: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        Schema1.self,
        Schema2.self,
    ]

    static let stages: [MigrationStage] = [
        migrateSchema1to2
    ]

    static let migrateSchema1to2 = MigrationStage.custom(
        fromVersion: Schema1.self, toVersion: Schema2.self,
        willMigrate: { context in
            print("@@, will migrate", context)
        },
        didMigrate: { context in
            print("@@, did migrate", context)
        })
}
