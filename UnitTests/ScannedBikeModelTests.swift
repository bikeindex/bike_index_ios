//
//  ScannedBikeModelTests.swift
//  UnitTests
//
//  Created by Jack on 5/11/25.
//

import Foundation
import SwiftData
import Testing

@testable import BikeIndex

@MainActor
struct ScannedBikeModelTests {

    struct Input: CustomTestArgumentEncodable {
        let numberOfStickers: Int
        let testSamples: [(URL, Date)]
        let expectedNumberOfStickers: Int

        var scannedBikesHistory: [ScannedBike] {
            testSamples.map { (url, createdAt) in
                let sticker = url.lastPathComponent
                return ScannedBike(sticker: sticker, url: url, createdAt: createdAt)
            }
        }

        enum CodingKeys: String, CodingKey {
            case numberOfStickers
            case testSamples
            case expectedNumberOfStickers
        }

        init(numberOfStickers: Int = 20, genesisBase: Date, expectedNumberOfStickers: Int = 10) {
            self.numberOfStickers = numberOfStickers
            self.testSamples = (0..<numberOfStickers).map { index in
                let url = URL(string: "https://bikeindex.org/bikes/scanned/\(index)")!
                let createdAt = genesisBase.addingTimeInterval(-TimeInterval(index * 60))
                return (url, createdAt)
            }
            self.expectedNumberOfStickers = expectedNumberOfStickers
        }

        func encodeTestArgument(to encoder: some Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(numberOfStickers, forKey: .numberOfStickers)
            let testData = testSamples.map { "\($0)-\($1)" }
            try container.encode(testData, forKey: .testSamples)
            try container.encode(expectedNumberOfStickers, forKey: .expectedNumberOfStickers)
        }

        var invocationName: String {
            let ids = scannedBikesHistory.map(\.sticker).joined(separator: "_")
            let firstId = ids.first ?? "0"
            let lastId = ids.last ?? "0"
            let dates = scannedBikesHistory.map(\.createdAt.timeIntervalSince1970.description)
            let firstDate = dates.first ?? ""
            let lastDate = dates.last ?? ""
            return
                "\(numberOfStickers).\(firstId)_\(lastId).\(firstId)_\(lastDate).\(expectedNumberOfStickers)"
        }
    }

    /// ``ScannedBikesViewModel`` must only persists the:
    /// 1. Ten (10) most recent stickers
    /// 2. Stickers created within the last two weeks.
    /// All scanned bike stickers older, or in greater quantity, must be forgotten.
    @Test(
        "Scanned Sticker History Data Layer",
        arguments: [
            Input(numberOfStickers: 1, genesisBase: Date(), expectedNumberOfStickers: 1),
            Input(numberOfStickers: 10, genesisBase: Date()),
            Input(numberOfStickers: 5, genesisBase: Date(), expectedNumberOfStickers: 5),
            Input(
                numberOfStickers: 10, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 21),
                expectedNumberOfStickers: 0),
            Input(numberOfStickers: 10, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 13)),
            Input(
                numberOfStickers: 20, genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 14 + 1)
            ),
            Input(numberOfStickers: 20, genesisBase: Date()),
        ])
    func test_handleStickerDeeplinks(input: Input) async throws {
        let invocationName = input.invocationName
        let config = ModelConfiguration(
            invocationName, isStoredInMemoryOnly: true, allowsSave: true)
        let container = try! ModelContainer(
            for: ScannedBike.self,
            configurations: config
        )
        let context = container.mainContext
        context.autosaveEnabled = false
        let model = ScannedBikesViewModel(
            context: context,
            client: try! Client())

        let fetch = FetchDescriptor(predicate: #Predicate<ScannedBike> { _ in true })
        let beginningState = try context.fetchCount(fetch)
        #expect(beginningState == 0)

        #expect(
            context.hasChanges == false,
            "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)"
        )

        do {
            try input.scannedBikesHistory.forEach { sticker in
                try model.persist(sticker: sticker)
            }
        } catch {
            #expect(false, "unexpected error \(error)")
        }

        #expect(
            context.hasChanges == false,
            "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)"
        )
        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(endState == input.expectedNumberOfStickers)
    }
}
