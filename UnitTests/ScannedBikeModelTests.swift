//
//  ScannedBikeModelTests.swift
//  UnitTests
//
//  Created by Jack on 5/11/25.
//

import Foundation
import Testing
import SwiftData
@testable import BikeIndex

@MainActor
struct ScannedBikeModelTests {

    @Test func test_handleDeeplink_once() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
        let container = try ModelContainer(
            for: ScannedBike.self,
            configurations: config
        )
        let context = container.mainContext

        let model = ScannedBikesViewModel(context: context,
                                          client: try! Client())

        let beginningState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(beginningState == 0)

        let stickerUrl1 = URL(string: "https://bikeindex.org/bikes/scanned/A40340")!

        model.handleDeeplink(stickerUrl1)

        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(endState == 1)
    }

}
