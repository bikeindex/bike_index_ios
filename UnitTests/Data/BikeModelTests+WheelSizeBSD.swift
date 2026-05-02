//
//  BikeModelTests+WheelSizeBSD.swift
//  UnitTests
//
//  Created by Jack on 5/2/26.
//

import Testing
@testable import BikeIndex
import Foundation

struct BikeModelTests_WheelSizeBSD {

    @Test func test_wheel_size_bsd() async throws {
        let rawJsonData = try #require(MockData.fullContainerWheelSize.data(using: .utf8))
        let output = try JSONDecoder().decode(FullBikeResponseContainer.self, from: rawJsonData)
        let bike = output.bike.modelInstance()

        #expect(bike.rearWheelSizeISOBSD == 622)
        #expect(bike.frontWheelSizeISOBSD == 622)
    }

}
