//
//  RegisterBikeViewModelTests.swift
//  UnitTests
//
//  Created by Jack on 8/9/25.
//

import Testing

@testable import BikeIndex

@MainActor
struct RegisterBikeViewModelTests {
    typealias ViewModel = RegisterBikeView.ViewModel

    @Test func test_inputs() async throws {
        let testBike = Bike()
        let testPropulsion = BikeRegistration.Propulsion()
        let testStolenRecord = StolenRecord(phone: "", city: "")
        let testOutput = AddBikeOutput()

        let system = ViewModel(
            mode: .myOwnBike,
            bike: testBike,
            propulsion: testPropulsion,
            stolenRecord: testStolenRecord,
            output: testOutput)

        #expect(system.missingSerial == false)
        #expect(system.manufacturerSearchText.isEmpty)
        #expect(system.frameModel.isEmpty)
        #expect(system.ownerEmail.isEmpty)

        #expect(system.requiredFieldsNotMet == true)
        #expect(system.isSerialNumberValid == false)
        #expect(system.isManufacturerValid == false)
        #expect(system.isFrameColorValid == true)
        #expect(system.isOwnerValid == false)
        #expect(
            system.remainingRequiredFields == "¼",
            "Frame color should always provide '¼' valid because it has a default value.")

        #expect(system.bike.createdAt == .distantPast)
        #expect(system.bike.updatedAt == .distantPast)

        testBike.manufacturerName = "Test"
        system.manufacturerSearchText = "Test"
        #expect(system.manufacturerSearchText.isEmpty == false)
        #expect(system.isManufacturerValid)
        #expect(
            system.remainingRequiredFields == "²⁄₄",
            "Frame color should always provide '²⁄₄' valid because it has a default value.")
    }

}
