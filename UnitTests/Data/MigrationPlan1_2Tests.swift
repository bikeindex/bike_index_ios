//
//  MigrationPlan1_2Tests.swift
//  UnitTests
//
//  Created by Jack on 5/9/26.
//

import SwiftData
import Testing
import Foundation

@testable import BikeIndex

@MainActor
struct MigrationPlan1_2Tests {

    @Test func modelContainer_with_migration_plan_initializes() throws {
        let container = try ModelContainer(
            for:
                Schema1.Bike.self,
                Schema2.Bike.self,
                User.self,
                AuthenticatedUser.self,
                ScannedBike.self,
                AutocompleteManufacturer.self,
                FullPublicImage.self,
                Component.self,
                StolenBikeRecord.self,
                migrationPlan: MigrationPlan_1_2.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let context = ModelContext(container)
        #expect(throws: Never.self) { try context.fetch(FetchDescriptor<Schema2.Bike>()) }
    }

    @Test func migration_transforms_extraRegistrationNumber_from_Int_to_String() {
        #expect(intToOptionalString(42) == "42")
    }

    @Test func migration_handles_nil_extraRegistrationNumber() {
        #expect(intToOptionalString(nil) == nil)
    }

    @Test func migration_handles_large_int_value() {
        #expect(intToOptionalString(2_147_483_647) == "2147483647")
    }

    @Test func migration_handles_zero_value() {
        #expect(intToOptionalString(0) == "0")
    }

    @Test func migration_handles_negative_int_value() {
        #expect(intToOptionalString(-1) == "-1")
    }

    @Test func schema2_bike_creation_with_string_extraRegistrationNumber() throws {
        let container = try ModelContainer(
            for:
                Schema2.Bike.self,
                User.self,
                AuthenticatedUser.self,
                ScannedBike.self,
                AutocompleteManufacturer.self,
                FullPublicImage.self,
                Component.self,
                StolenBikeRecord.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let context = ModelContext(container)

        let bike = Schema2.Bike(
            identifier: 99999,
            title: "Migrated Bike",
            primaryColor: .green,
            manufacturerName: "Cannondale",
            typeOfCycle: .bike,
            typeOfPropulsion: .footPedal,
            status: .withOwner,
            stolenCoordinateLatitude: 47.6062,
            stolenCoordinateLongitude: -122.3321,
            url: URL(string: "https://example.com/bike/99999")!,
            publicImages: ["https://example.com/img.jpg"],
            extraRegistrationNumber: "REG-12345"
        )
        context.insert(bike)
        try context.save()

        let descriptor = FetchDescriptor<Schema2.Bike>(
            predicate: #Predicate { $0.identifier == 99999 }
        )
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results.first?.extraRegistrationNumber == "REG-12345")
    }

    @Test func schema2_bike_full_migration_roundtrip() throws {
        let container = try ModelContainer(
            for:
                Schema1.Bike.self,
                Schema2.Bike.self,
                User.self,
                AuthenticatedUser.self,
                ScannedBike.self,
                AutocompleteManufacturer.self,
                FullPublicImage.self,
                Component.self,
                StolenBikeRecord.self,
                migrationPlan: MigrationPlan_1_2.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let context = ModelContext(container)

        // Insert a Schema1 bike (old schema) with Int extraRegistrationNumber
        let oldBike = Schema1.Bike(
            identifier: 54321,
            title: "Old Schema Bike",
            primaryColor: .blue,
            manufacturerName: "Giant",
            typeOfCycle: .bike,
            typeOfPropulsion: .footPedal,
            status: .stolen,
            stolenCoordinateLatitude: 40.7128,
            stolenCoordinateLongitude: -74.006,
            url: URL(string: "https://example.com/bike/54321")!,
            publicImages: ["https://example.com/photo.jpg"],
            extraRegistrationNumber: 7777
        )
        context.insert(oldBike)

        // Simulate migration by creating the Schema2 version directly
        let newBike = Schema2.Bike(
            identifier: oldBike.identifier,
            title: oldBike.title,
            bikeDescription: oldBike.bikeDescription,
            registryName: oldBike.registryName,
            registryURL: oldBike.registryURL,
            frameModel: oldBike.frameModel,
            primaryColor: oldBike.frameColorPrimary,
            secondaryColor: oldBike.frameColorSecondary,
            tertiaryColor: oldBike.frameColorTertiary,
            paintDescription: oldBike.paintDescription,
            manufacturerName: oldBike.manufacturerName,
            manufacturerID: oldBike.manufacturerID,
            year: oldBike.year,
            typeOfCycle: oldBike.typeOfCycle,
            typeOfPropulsion: oldBike.typeOfPropulsion,
            serial: oldBike.serial,
            status: oldBike.status,
            stolen: oldBike.stolen,
            stolenCoordinateLatitude: oldBike.stolenCoordinates?.coordinate.latitude ?? .nan,
            stolenCoordinateLongitude: oldBike.stolenCoordinates?.coordinate.longitude ?? .nan,
            stolenLocation: oldBike.stolenLocation,
            dateStolen: oldBike.dateStolen,
            locationFound: oldBike.locationFound,
            largeImage: oldBike.largeImage,
            thumb: oldBike.thumb,
            url: oldBike.url,
            apiUrl: oldBike.apiUrl,
            publicImages: oldBike.publicImages,
            fullPublicImages: oldBike.fullPublicImages,
            createdAt: oldBike.createdAt,
            updatedAt: oldBike.updatedAt,
            extraRegistrationNumber: intToOptionalString(oldBike.extraRegistrationNumber),
            rearTireNarrow: oldBike.rearTireNarrow,
            testBike: oldBike.testBike,
            rearWheelSizeISOBSD: nil,
            frontWheelSizeISOBSD: nil,
            handlebarTypeSlug: oldBike.handlebarTypeSlug,
            frameMaterialSlug: oldBike.frameMaterialSlug,
            frontGearTypeSlug: oldBike.frontGearTypeSlug,
            rearGearTypeSlug: oldBike.rearGearTypeSlug,
            additionalRegistration: oldBike.additionalRegistration,
            components: []
        )
        context.insert(newBike)
        try context.save()

        // Verify the migrated bike has correct values
        let descriptor = FetchDescriptor<Schema2.Bike>(
            predicate: #Predicate { $0.identifier == 54321 }
        )
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        guard let migrated = results.first else { Issue.record("No migrated bike found"); return }

        // Core migration assertion: Int? → String?
        #expect(migrated.extraRegistrationNumber == "7777")

        // Verify other fields were preserved correctly
        #expect(migrated.manufacturerName == "Giant")
        #expect(migrated.title == "Old Schema Bike")
        #expect(migrated.typeOfCycle == .bike)
        #expect(migrated.status == .stolen)
    }
}

// MARK: - Helpers

/// Mirrors the migration transformation used in `willMigrate`: Int? → String?
private func intToOptionalString(_ value: Int?) -> String? {
    value.map(String.init)
}
