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
class ScannedBikeModelTests {

    @Test func test_handleDeeplink_once() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
        let container = try! ModelContainer(
            for: ScannedBike.self,
            configurations: config
        )
        let context = container.mainContext
        context.autosaveEnabled = false
        let model = ScannedBikesViewModel(context: context,
                                          client: try! Client())
        do {
            let fetch = FetchDescriptor(predicate: #Predicate<ScannedBike> { _ in true })
            let beginningState = try context.fetchCount(fetch)
            #expect(beginningState == 0)

            let stickerUrl1 = URL(string: "https://bikeindex.org/bikes/scanned/A40340")!

            try model.handleDeeplink(stickerUrl1)

            let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
            #expect(endState == 1)
        } catch {
            print("Hit error \(error)")
        }
    }

    @Test func test_handleTwentyDeeplinks_expect10MostRecentOnly() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
        let container = try! ModelContainer(
            for: ScannedBike.self,
            configurations: config
        )
        let context = container.mainContext
        context.autosaveEnabled = false
        let model = ScannedBikesViewModel(context: context,
                                          client: try! Client())

        let fetch = FetchDescriptor(predicate: #Predicate<ScannedBike> { _ in true })
        let beginningState = try context.fetchCount(fetch)
        #expect(beginningState == 0)

        #expect(context.hasChanges == false, "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)")

        (0..<20).forEach { _ in
            let stickerUrl1 = URL(string: "https://bikeindex.org/bikes/scanned/A40340")!
            try! model.handleDeeplink(stickerUrl1)
        }

        #expect(context.hasChanges == false, "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)")
        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(endState == 10)
    }
}
