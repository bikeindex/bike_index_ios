//
//  MigrationPlans.swift
//  BikeIndex
//
//  Created by Jack on 10/4/25.
//

import SwiftData

enum MigrationPlan_v1_v2: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        BikeSchemaV1.self
    ]

    static let stages: [MigrationStage] = [
        migrateV1toV2
    ]

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: BikeSchemaV1.self,
        toVersion: BikeSchemaV2.self,
        willMigrate: { context in
            // remove duplicates then save
        }, didMigrate: nil
    )
}
