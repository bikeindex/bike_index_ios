//
//  FullBikeResponseTests.swift
//  UnitTests
//
//  Created by Milo Wyner on 1/10/26.
//

import Foundation
import MapKit
import Testing

@testable import BikeIndex

struct FullBikeResponseTests {

    @Test func parsingModel() throws {
        let rawJsonData = try #require(MockData.sampleFullBikeJson.data(using: .utf8))
        let output = try JSONDecoder().decode(FullBikeResponse.self, from: rawJsonData)
        let bike = output.modelInstance()

        #expect(bike.identifier == 20348)
        #expect(bike.title == "2012 Giant Trance X")
        #expect(bike.bikeDescription == "26 Giant Trance X  ")
        #expect(bike.registryName == "MOCK_REGISTRY_NAME")
        #expect(bike.registryURL == URL(string: "https://bikeindex.org/MOCK_REGISTRY_URL"))
        #expect(bike.frameModel == "Trance X")
        #expect(bike.typeOfCycle == .bike)
        #expect(bike.frameColors == [.green, .blue])
        #expect(bike.paintDescription == "MOCK_PAINT_DESCRIPTION")
        #expect(bike.manufacturerName == "Giant")
        #expect(bike.manufacturerID == 153)
        #expect(bike.serial == "GS020355")

        #expect(bike.status == .stolen)
        #expect(bike.stolen == true)
        let stolenCoordinates = try #require(bike.stolenCoordinates)
        #expect(
            stolenCoordinates.distance(from: CLLocation(latitude: 45.53, longitude: -122.69))
                == CLLocationDistance(integerLiteral: 0))
        #expect(bike.dateStolen == Date(timeIntervalSince1970: 1_376_719_200))
        #expect(bike.locationFound == nil)

        #expect(bike.thumb == nil)
        #expect(bike.url == URL(string: "https://bikeindex.org/bikes/20348"))
        #expect(bike.apiUrl == URL(string: "https://bikeindex.org/api/v1/bikes/20348"))
        #expect(bike.publicImages == [])
        #expect(bike.isStockImage == false)

        #expect(bike.createdAt == Date(timeIntervalSince1970: 1_377_151_200))
        #expect(bike.updatedAt == Date(timeIntervalSince1970: 1_585_269_739))

        #expect(bike.extraRegistrationNumber == 12345)
        #expect(bike.rearTireNarrow == true)
        #expect(bike.testBike == false)
        #expect(bike.rearWheelSizeISOBSD == false)
        #expect(bike.frontWheelSizeISOBSD == false)
        #expect(bike.handlebarTypeSlug == "MOCK_HANDLEBAR_TYPE")
        #expect(bike.frameMaterialSlug == "MOCK_FRAME_MATERIAL")
        #expect(bike.frontGearTypeSlug == "MOCK_FRONT_GEAR_TYPE")
        #expect(bike.rearGearTypeSlug == "MOCK_REAR_GEAR_TYPE")
        #expect(bike.additionalRegistration == "MOCK_ADDITIONAL_REGISTRATION")
        
        let stolenRecord = try #require(bike.stolenRecord)
        #expect(stolenRecord.date_stolen == 1376719200)
        #expect(stolenRecord.location == "Portland, OR 97209, US")
        #expect(stolenRecord.latitude == 45.53)
        #expect(stolenRecord.longitude == -122.69)
        #expect(stolenRecord.theft_description == "Bike rack Reward: Tbd")
        #expect(stolenRecord.locking_description == nil)
        #expect(stolenRecord.lock_defeat_description == nil)
        #expect(stolenRecord.police_report_number == "1368801")
        #expect(stolenRecord.police_report_department == "Portland")
        #expect(stolenRecord.created_at == 1402778082)
        #expect(stolenRecord.create_open311 == false)
        #expect(stolenRecord.id == 16690)
        
        #expect(bike.components == ["MOCK_COMPONENT_1", "MOCK_COMPONENT_2"])
    }

}
