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

    struct Input {
        let numberOfStickers: Int
        let testSamples: [ScannedBike]
        let expectedNumberOfStickers: Int

        init(numberOfStickers: Int = 20, genesisBase: Date, expectedNumberOfStickers: Int = 10) {
            self.numberOfStickers = numberOfStickers
            self.testSamples = (0..<numberOfStickers).map { index in
                let url = URL(string: "https://bikeindex.org/bikes/scanned/\(index)")!
                let createdAt = genesisBase.addingTimeInterval(-TimeInterval(index))
                return ScannedBike(sticker: String(index), url: url, createdAt: createdAt)
            }
            self.expectedNumberOfStickers = expectedNumberOfStickers
        }

        var invocationName: String {
            let ids = testSamples.map(\.sticker).joined(separator: "_")
            let firstId = ids.first ?? "0"
            let lastId = ids.last ?? "0"
            let dates = testSamples.map(\.createdAt.timeIntervalSince1970.description)
            let firstDate = dates.first ?? ""
            let lastDate = dates.last ?? ""
            return "\(numberOfStickers).\(firstId)_\(lastId).\(firstId)_\(lastDate).\(expectedNumberOfStickers)"
        }
    }

    /// ``ScannedBikesViewModel`` must only persists the:
    /// 1. Ten (10) most recent stickers
    /// 2. Stickers created within the last two weeks.
    /// All scanned bike stickers older, or in greater quantity, must be forgotten.
    @Test(arguments: [
        Input(numberOfStickers: 1, genesisBase: Date(), expectedNumberOfStickers: 1),
        Input(numberOfStickers: 10, genesisBase: Date()),
        Input(numberOfStickers: 5, genesisBase: Date(), expectedNumberOfStickers: 5),
        Input(numberOfStickers: 10, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 21), expectedNumberOfStickers: 0),
        Input(numberOfStickers: 10, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 13)),
        Input(numberOfStickers: 20, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 14 + 1)),
        Input(numberOfStickers: 20, genesisBase: Date())
    ])
    func test_handleStickerDeeplinks(input: Input) async throws {
        let invocationName = input.invocationName
        let config = ModelConfiguration(invocationName, isStoredInMemoryOnly: true, allowsSave: true)
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

        do {
            try input.testSamples.forEach { sticker in
                try model.persist(sticker: sticker)
            }
        } catch {
            #expect(false, "unexpected error \(error)")
        }

        #expect(context.hasChanges == false, "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)")
        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(endState == input.expectedNumberOfStickers)
    }
}
