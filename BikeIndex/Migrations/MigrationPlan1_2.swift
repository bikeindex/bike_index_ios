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
            let schema1Bikes = try! context.fetch(FetchDescriptor<Schema1.Bike>())

            for schema1Bike in schema1Bikes {
                let schema2Bike = Schema2.Bike(
                    identifier: schema1Bike.identifier,
                    title: schema1Bike.title,
                    bikeDescription: schema1Bike.bikeDescription,
                    registryName: schema1Bike.registryName,
                    registryURL: schema1Bike.registryURL,
                    frameModel: schema1Bike.frameModel,
                    primaryColor: schema1Bike.frameColorPrimary,
                    secondaryColor: schema1Bike.frameColorSecondary,
                    tertiaryColor: schema1Bike.frameColorTertiary,
                    paintDescription: schema1Bike.paintDescription,
                    manufacturerName: schema1Bike.manufacturerName,
                    manufacturerID: schema1Bike.manufacturerID,
                    year: schema1Bike.year,
                    typeOfCycle: schema1Bike.typeOfCycle,
                    typeOfPropulsion: schema1Bike.typeOfPropulsion,
                    serial: schema1Bike.serial,
                    status: schema1Bike.status,
                    stolen: schema1Bike.stolen,
                    stolenCoordinateLatitude: schema1Bike.stolenCoordinateLatitude,
                    stolenCoordinateLongitude: schema1Bike.stolenCoordinateLongitude,
                    stolenLocation: schema1Bike.stolenLocation,
                    dateStolen: schema1Bike.dateStolen,
                    locationFound: schema1Bike.locationFound,
                    largeImage: schema1Bike.largeImage,
                    thumb: schema1Bike.thumb,
                    url: schema1Bike.url,
                    apiUrl: schema1Bike.apiUrl,
                    publicImages: schema1Bike.publicImages,
                    fullPublicImages: migrateFullPublicImages(from: schema1Bike.fullPublicImages),
                    createdAt: schema1Bike.createdAt,
                    updatedAt: schema1Bike.updatedAt,
                    extraRegistrationNumber: schema1Bike.extraRegistrationNumber.map(String.init),
                    rearTireNarrow: schema1Bike.rearTireNarrow,
                    testBike: schema1Bike.testBike,
                    rearWheelSizeISOBSD: nil,
                    frontWheelSizeISOBSD: nil,
                    handlebarTypeSlug: schema1Bike.handlebarTypeSlug,
                    frameMaterialSlug: schema1Bike.frameMaterialSlug,
                    frontGearTypeSlug: schema1Bike.frontGearTypeSlug,
                    rearGearTypeSlug: schema1Bike.rearGearTypeSlug,
                    additionalRegistration: schema1Bike.additionalRegistration,
                    components: []
                )

                context.insert(schema2Bike)
            }
        },
        didMigrate: { context in
            print("@@, did migrate", context)
        })

    private static func migrateFullPublicImages(from oldImages: [String]) -> [FullPublicImage] {
        oldImages.compactMap { urlString in
            guard let url = URL(string: urlString) else { return nil }
            return FullPublicImage(name: "", full: url, large: url, medium: nil, thumb: nil, id: 0)
        }
    }
}
