//
//  BikeModelTests.swift
//  UnitTests
//
//  Created by Jack on 11/18/23.
//

import MapKit
import XCTest

@testable import BikeIndex

final class BikeModelTests: XCTestCase {

    /// Make sure that parsing a sample Bike from production works
    func test_parsing_model() throws {
        let rawJsonData = try XCTUnwrap(MockData.sampleBikeJson.data(using: .utf8))
        let output = try JSONDecoder().decode(SimpleBikeResponse.self, from: rawJsonData)
        let bike = output.modelInstance()

        XCTAssertEqual(bike.identifier, 20348)
        XCTAssertEqual(bike.bikeDescription, "26 Giant Trance X  ")
        XCTAssertEqual(bike.frameModel, "Trance X")
        XCTAssertEqual(bike.typeOfCycle, .bike)
        XCTAssertEqual(bike.frameColors, [.green, .blue])
        XCTAssertEqual(bike.manufacturerName, "Giant")
        XCTAssertEqual(bike.serial, "GS020355")

        XCTAssertEqual(bike.createdAt, nil)
        XCTAssertEqual(bike.updatedAt, nil)

        XCTAssertEqual(bike.status, .stolen)
        let stolenCoordinates = try XCTUnwrap(bike.stolenCoordinates)
        XCTAssertEqual(
            stolenCoordinates.distance(from: CLLocation(latitude: 45.53, longitude: -122.69)),
            CLLocationDistance(integerLiteral: 0))
        XCTAssertEqual(bike.dateStolen, Date(timeIntervalSince1970: 1_376_719_200))

        XCTAssertNil(bike.thumb)
        XCTAssertEqual(bike.url, URL(string: "https://bikeindex.org/bikes/20348"))
        XCTAssertEqual(bike.apiUrl, URL(string: "https://bikeindex.org/api/v1/bikes/20348"))
        XCTAssertEqual(bike.publicImages, [])
    }

    // TODO: This can be completed when Bike.swift and BikeResponse.swift support **ALL** fields, full parity with the API - relies on https://github.com/bikeindex/bike_index_ios/pull/107
    /// Make sure that parsing JSON into a Bike model and encoding it back to JSON is idempotent.
    func test_reading_writing_json() throws {
        let rawJsonData = try XCTUnwrap(MockData.sampleBikeJson.data(using: .utf8))
        let parsedModel = try JSONDecoder().decode(SimpleBikeResponse.self, from: rawJsonData)

        let bike = parsedModel.modelInstance()

        let registrationInstance = BikeRegistration(
            bike: bike,
            mode: .myOwnBike,
            stolen: nil,
            propulsion: nil,
            ownerEmail: ""
        )
        let json = try JSONEncoder().encode(registrationInstance)
        let modelString = String(data: json, encoding: .utf8).unsafelyUnwrapped

        XCTAssertEqual(MockData.sampleBikeJson, modelString)
    }
}
