//
//  BikeModelTests+Components.swift
//  UnitTests
//
//  Created by Jack on 5/2/26.
//

import Foundation
import Testing

@testable import BikeIndex

struct BikeModelTests_Components {

    @Test func test_components() async throws {
        let rawJsonData = try #require(
            MockData.fullContainerWheelSize_Components.data(using: .utf8))
        let output = try JSONDecoder().decode(FullBikeResponseContainer.self, from: rawJsonData)
        let bike = output.bike.modelInstance()

        #expect(bike.components.isEmpty == false)
        #expect(bike.components.count == 1)
    }

}
