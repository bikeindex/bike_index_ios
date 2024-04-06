//
//  BikeRegistration.swift
//  BikeIndexTests
//
//  Created by Jack on 12/28/23.
//

import XCTest
@testable import BikeIndex

final class BikeRegistrationTests: XCTestCase {

    /// Ensure that the BikeRegistration model uses lower-case values for the frame colors.
    /// All other frame color usages must be title-case.
    func test_bike_registration_lowercase_color() throws {
        let rawJsonData = try XCTUnwrap(MockData.sampleBikeJson.data(using: .utf8))
        let output = try JSONDecoder().decode(BikeResponse.self, from: rawJsonData)
        let bike = output.modelInstance()

        bike.frameColorTertiary = .covered
        let registrationModel = BikeRegistration(bike: bike,
                                                 mode: .myOwnBike,
                                                 stolen: nil,
                                                 ownerEmail: "")

        XCTAssertEqual(registrationModel.primary_frame_color, "green")
        XCTAssertEqual(registrationModel.secondary_frame_color, "blue")
        XCTAssertEqual(registrationModel.tertiary_frame_color, "stickers tape or other cover-up")

        XCTAssertEqual(registrationModel.cycle_type_name, .bike)
        XCTAssertEqual(registrationModel.propulsion_type_slug, .footPedal)
    }

}
