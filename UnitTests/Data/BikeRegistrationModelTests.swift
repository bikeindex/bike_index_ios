//
//  BikeRegistrationModelTests.swift
//  UnitTests
//
//  Created by Jack on 12/28/23.
//

import Foundation
import Testing

@testable import BikeIndex

struct BikeRegistrationModelTests {
    /// Ensure that the BikeRegistration model uses lower-case values for the frame colors.
    /// All other frame color usages must be title-case.
    @Test func test_lowercase_color() throws {
        let rawJsonData = try #require(MockData.sampleBikeJson.data(using: .utf8))
        let output = try JSONDecoder().decode(SimpleBikeResponse.self, from: rawJsonData)
        let bike = output.modelInstance()

        bike.frameColorTertiary = .covered
        let registrationModel = BikeRegistration(
            bike: bike,
            mode: .myOwnBike,
            stolen: nil,
            propulsion: nil,
            ownerEmail: "")

        #expect(registrationModel.primary_frame_color == "green")
        #expect(registrationModel.secondary_frame_color == "blue")
        #expect(registrationModel.tertiary_frame_color == "stickers tape or other cover-up")

        #expect(registrationModel.cycle_type_name == .bike)
        #expect(registrationModel.propulsion == nil)
    }

    /// Ensure that Bike -> BikeRegistration -> `serial` data flow is correct
    @Test func test_unknown_serial() {
        let unknownSerialBike = Bike()

        let registrationModel = BikeRegistration(
            bike: unknownSerialBike, mode: .myOwnBike, stolen: nil, propulsion: nil,
            ownerEmail: "tester@bikeindex.org")
        #expect(registrationModel.serial == "unknown")
    }
}
