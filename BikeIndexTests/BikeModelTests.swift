//
//  BikeModelTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/18/23.
//

import XCTest
import MapKit

final class BikeModelTests: XCTestCase {

    /// Make sure that parsing a sample Bike from production works
    func test_parsing_model() throws {
        let rawJsonData = try XCTUnwrap(MockData.sampleBikeJson.data(using: .utf8))
        let output = try JSONDecoder().decode(Bike.self, from: rawJsonData)

        XCTAssertEqual(output.identifier, 20348)
        XCTAssertEqual(output.bikeDescription, "26 Giant Trance X  ")
        XCTAssertEqual(output.frameModel, "Trance X")
        XCTAssertEqual(output.typeOfCycle, .bike)
        XCTAssertEqual(output.frameColors, [.green, .blue])
        XCTAssertEqual(output.manufacturerName, "Giant")
        XCTAssertEqual(output.serial, "GS020355")

        XCTAssertEqual(output.status, .stolen)
        let stolenCoordinates = try XCTUnwrap(output.stolenCoordinates)
        XCTAssertEqual(stolenCoordinates.distance(from: CLLocation(latitude: 45.53, longitude: -122.69)),
                       CLLocationDistance(integerLiteral: 0))
        XCTAssertEqual(output.dateStolen, Date(timeIntervalSince1970: 1376719200))

        XCTAssertNil(output.thumb)
        XCTAssertEqual(output.url, URL(string: "https://bikeindex.org/bikes/20348"))
        XCTAssertEqual(output.apiUrl, URL(string: "https://bikeindex.org/api/v1/bikes/20348"))
        XCTAssertEqual(output.publicImages, [])
    }

    /// Make sure that parsing JSON into a Bike model and encoding it back to JSON is idempotent.
    func test_reading_writing_json() throws {
        let rawJsonData = try XCTUnwrap(MockData.sampleBikeJson.data(using: .utf8))
        let parsedModel = try JSONDecoder().decode(Bike.self, from: rawJsonData)

        let json = try JSONEncoder().encode(parsedModel)
        let modelString = String(data: json, encoding: .utf8).unsafelyUnwrapped

        XCTAssertEqual(MockData.sampleBikeJson, modelString)
    }
}

