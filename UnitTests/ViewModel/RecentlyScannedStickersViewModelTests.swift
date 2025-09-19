//
//  RecentlyScannedStickersViewModelTests.swift
//  UnitTests
//
//  Created by Jack on 5/11/25.
//

import Foundation
import SwiftData
import Testing

@testable import BikeIndex

/// Aka RecentlyScannedStickersView.ViewModel
@MainActor
struct RecentlyScannedStickersViewModelTests {
    typealias ViewModel = RecentlyScannedStickersView.ViewModel

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

        /// Initialize a test input, will create an array of scanned bike QR stickers, increasingly older, for testing.
        /// - Parameters:
        ///   - numberOfStickers: How many stickers to write. Defaults to 20, exceeding the default limit.
        ///   - genesisBase: The start date, which is adjusted to be 1-minute older for every sticker beyond the first one.
        ///   - expectedNumberOfStickers: The maximum number of stickers that should be saved in this write. Defaults to limit of 10.
        init(
            numberOfStickers: Int = 20,
            genesisBase: Date = .now,
            expectedNumberOfStickers: Int = ViewModel.limitOfMostRecent
        ) {
            self.numberOfStickers = numberOfStickers
            self.testSamples = (0..<numberOfStickers).map { index in
                let url = URL(string: "https://bikeindex.org/bikes/scanned/\(index)")!
                let offset = -TimeInterval(index * 60)
                let createdAt = genesisBase.addingTimeInterval(offset)
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
                "\(numberOfStickers).\(firstId)_\(lastId).\(firstDate)_\(lastDate).\(expectedNumberOfStickers)"
        }
    }

    /// ``ScannedBikesViewModel`` must only persists the:
    /// 1. Ten (10) most recent stickers
    /// 2. Stickers created within the last two weeks.
    /// All scanned bike stickers older, or in greater quantity, must be forgotten.
    @Test(
        "Scanned Sticker History Data Layer",
        arguments: [
            Input(  // count within 10, date within 2 weeks ago
                numberOfStickers: 10,
                expectedNumberOfStickers: 10),
            Input(  // count within 10, date outside of 2 weeks ago
                numberOfStickers: 10,
                genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 21),
                expectedNumberOfStickers: 0),
            Input(  // count within 10, date within 2 weeks ago
                numberOfStickers: 10,
                genesisBase: Date().addingTimeInterval(-60 * 60 * 24 * 13)),
            Input(  // count outside of 10, date within 2 weeks ago
                numberOfStickers: 20),
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
        let model = ViewModel()

        let fetch = FetchDescriptor(predicate: #Predicate<ScannedBike> { _ in true })
        let beginningState = try context.fetchCount(fetch)
        #expect(beginningState == 0)

        #expect(
            context.hasChanges == false,
            "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)"
        )

        do {
            for sticker in input.scannedBikesHistory {
                _ = try model.persist(context: context, sticker: sticker)
            }
        } catch {
            #expect(Bool(false), "unexpected error \(error)")
        }

        #expect(
            context.hasChanges == false,
            "\(type(of: self)) should not have pending changes before reaching body of test function \(#function)"
        )

        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        #expect(
            endState == input.expectedNumberOfStickers,
            "Expected to find \(input.expectedNumberOfStickers) but actually found \(endState)")

        // Ensure that the 10-most-recent dates in the Input are the same 10-most-recent dates
        // written to the database.
        let mostRecentInput = input.scannedBikesHistory
            .map(\.createdAt)
            .sorted(by: >)
            .prefix(upTo: 10)

        let outputPersistedModels = try context.fetch(FetchDescriptor<ScannedBike>())
        let zipped = zip(mostRecentInput, outputPersistedModels)
        #expect(zipped.underestimatedCount == input.expectedNumberOfStickers)
        for (mostRecent, persisted) in zipped {
            #expect(mostRecent == persisted.createdAt)
        }
    }
}
