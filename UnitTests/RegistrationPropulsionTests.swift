//
//  RegistrationPropulsionTests.swift
//  UnitTests
//
//  Created by Jack on 4/7/24.
//

import OSLog
import URLEncodedForm
import XCTest

@testable import BikeIndex

final class RegistrationPropulsionTests: XCTestCase {

    let urlFormEncoder = URLEncodedFormEncoder()
    /// Used to compose models and test the output.
    let baseBike = Bike(
        identifier: 1234,
        primaryColor: .bareMetal,
        manufacturerName: "",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0,
        stolenCoordinateLongitude: 0,
        url: URL(string: "about:blank")!,
        publicImages: [])

    func test_propulsion_invalid_states_var_closed() throws {
        var propulsion = BikeRegistration.Propulsion(
            isElectric: false,
            hasThrottle: true,
            hasPedalAssist: true
        )

        propulsion.isElectric = false

        XCTAssertFalse(propulsion.isElectric)
        XCTAssertFalse(propulsion.hasThrottle)
        XCTAssertFalse(propulsion.hasPedalAssist)
    }

    func test_propulsion_invalid_states_var_forward() throws {
        var propulsion = BikeRegistration.Propulsion(
            isElectric: false,
            hasThrottle: true,
            hasPedalAssist: true
        )

        propulsion.isElectric = true

        XCTAssertTrue(propulsion.isElectric)
        XCTAssertFalse(propulsion.hasThrottle)
        XCTAssertFalse(propulsion.hasPedalAssist)
    }

    func test_propulsion_invalid_states_init() throws {
        let propulsion = BikeRegistration.Propulsion(
            isElectric: false,
            hasThrottle: true,
            hasPedalAssist: true
        )

        XCTAssertFalse(propulsion.isElectric)
        XCTAssertFalse(propulsion.hasThrottle)
        XCTAssertFalse(propulsion.hasPedalAssist)
    }

    func test_registration_composed_with_non_propulsion() throws {
        let propulsion = BikeRegistration.Propulsion(
            isElectric: false,
            hasThrottle: true,
            hasPedalAssist: true
        )

        let registration = registration(with: propulsion)

        XCTAssertEqual(registration.cycle_type_name, .bike)

        let formDataString = try formDataString(from: registration)
        let delimitedFormContents = formDataString.split(separator: "&")
        let prettyFormString = delimitedFormContents.joined(separator: "&\n")
        Logger.tests.debug("Encoded value is \n\(prettyFormString, privacy: .public)")

        XCTAssertTrue(formDataString.contains("cycle_type_name=bike"))

        XCTAssertFalse(formDataString.contains("propulsion_type_motorized"))
        XCTAssertFalse(formDataString.contains("propulsion_type_throttle"))
        XCTAssertFalse(formDataString.contains("propulsion_type_pedal_assist"))
    }

    /// Electric = true, has throttle = true, has pedal assist = true
    func test_registration_composed_with_full_propulsion() throws {
        let propulsion = BikeRegistration.Propulsion(
            isElectric: true,
            hasThrottle: true,
            hasPedalAssist: true
        )

        let registration = registration(with: propulsion)

        XCTAssertEqual(registration.cycle_type_name, .bike)

        let formDataString = try formDataString(from: registration)
        let delimitedFormContents = formDataString.split(separator: "&")
        let prettyFormString = delimitedFormContents.joined(separator: "&\n")
        Logger.tests.debug("Encoded value is \n\(prettyFormString, privacy: .public)")

        XCTAssertTrue(formDataString.contains("cycle_type_name=bike"))

        XCTAssertFalse(formDataString.contains("propulsion_type_motorized"))
        XCTAssertTrue(formDataString.contains("propulsion_type_throttle"))
        XCTAssertTrue(formDataString.contains("propulsion_type_pedal_assist"))
    }

    /// Electric = true, has throttle = false, has pedal assist = false
    func test_registration_composed_with_just_electric_propulsion() throws {
        let propulsion = BikeRegistration.Propulsion(
            isElectric: true,
            hasThrottle: false,
            hasPedalAssist: false
        )

        let registration = registration(with: propulsion)

        XCTAssertEqual(registration.cycle_type_name, .bike)

        let formDataString = try formDataString(from: registration)
        let delimitedFormContents = formDataString.split(separator: "&")
        let prettyFormString = delimitedFormContents.joined(separator: "&\n")
        Logger.tests.debug("Encoded value is \n\(prettyFormString, privacy: .public)")

        XCTAssertTrue(formDataString.contains("cycle_type_name=bike"))

        XCTAssertTrue(formDataString.contains("propulsion_type_motorized"))
        XCTAssertFalse(formDataString.contains("propulsion_type_throttle"))
        XCTAssertFalse(formDataString.contains("propulsion_type_pedal_assist"))
    }

    // MARK: - Helpers

    func registration(with propulsion: BikeRegistration.Propulsion) -> BikeRegistration {
        return BikeRegistration(
            bike: baseBike,
            mode: .myOwnBike,
            stolen: nil,
            propulsion: propulsion,
            ownerEmail: "test@example.com"
        )
    }

    func formDataString(from registration: BikeRegistration) throws -> String {
        let formOutput = try urlFormEncoder.encode(registration)
        let formString = try XCTUnwrap(String(data: formOutput, encoding: .utf8))
        return formString
    }

}
