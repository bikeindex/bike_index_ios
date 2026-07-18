//
//  StickerCenterViewModelTests.swift
//  UnitTests
//
//  Created by Jack on 5/11/25.
//

import Foundation
import SwiftData
import Testing

@testable import BikeIndex

/// Tests for StickerCenter.ViewModel - date-based sticker expiration only
@MainActor
struct StickerCenterViewModelTests {

    let hostProvider = HostProvider(host: URL("https://bikeindex.org"))

    struct Input: CustomTestArgumentEncodable {
        let numberOfStickers: Int
        let dateRange: DateRange
        let expectedNumberOfStickers: Int

        var scannedBikesHistory: [ScannedBike] {
            (0..<numberOfStickers).map { index in
                let url = URL(string: "https://bikeindex.org/bikes/scanned/\(index)")!
                let createdAt = Date.now.addingTimeInterval(dateRange.rawValue)
                return ScannedBike(sticker: "\(index)", url: url, createdAt: createdAt)
            }
        }

        enum CodingKeys: String, CodingKey {
            case numberOfStickers
            case dateRange
            case expectedNumberOfStickers
        }

        init(
            numberOfStickers: Int = 10,
            dateRange: DateRange = .now,
            expectedNumberOfStickers: Int
        ) {
            self.numberOfStickers = numberOfStickers
            self.dateRange = dateRange
            self.expectedNumberOfStickers = expectedNumberOfStickers
        }

        func encodeTestArgument(to encoder: some Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(numberOfStickers, forKey: .numberOfStickers)
            try container.encode(dateRange.rawValue, forKey: .dateRange)  // hack to include dates
            try container.encode(expectedNumberOfStickers, forKey: .expectedNumberOfStickers)
        }

        var invocationName: String {
            let firstId = scannedBikesHistory.first?.sticker ?? "0"
            let lastId = scannedBikesHistory.last?.sticker ?? "0"
            let firstDate =
                scannedBikesHistory.first?.createdAt.timeIntervalSince1970.description ?? ""
            let lastDate =
                scannedBikesHistory.last?.createdAt.timeIntervalSince1970.description ?? ""
            return
                "\(numberOfStickers).\(firstId)_\(lastId).\(firstDate)_\(lastDate).\(expectedNumberOfStickers)"
        }

        enum DateRange: TimeInterval {
            case now = 0
            /// 60 * 60 * 24 * 14 = 1,209,600 + 2min buffer
            case twoWeeksAgo = -1_209_720
        }
    }

    /// Date-based expiration only: all stickers within the last two weeks are preserved,
    /// regardless of count. All others are purged.
    @Test(
        "Scanned Sticker History Data Layer - Date-Based Expiration",
        arguments: [
            Input(
                numberOfStickers: 10,
                dateRange: .now,
                expectedNumberOfStickers: 10),
            Input(
                numberOfStickers: 10,
                dateRange: .twoWeeksAgo,
                expectedNumberOfStickers: 0),
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
        let model = StickerCenter.ViewModel()

        let fetch = FetchDescriptor(predicate: #Predicate<ScannedBike> { _ in true })
        let beginningState = try context.fetchCount(fetch)
        #expect(beginningState == 0)

        do {
            for sticker in input.scannedBikesHistory {
                let createdSticker = try model.persist(context: context, sticker: sticker)
                #expect(createdSticker.createdAt == sticker.createdAt)
            }
        } catch {
            #expect(Bool(false), "unexpected error \(error)")
        }

        context.processPendingChanges()
        try context.save()
        #expect(context.hasChanges == false)

        let endState = try! context.fetchCount(FetchDescriptor<ScannedBike>())
        if endState > 0 {
            let debug = try context.fetch(fetch)
            print("Debug sticker was created at: ", debug.map(\.createdAt), debug.map(\.sticker))
        }
        #expect(
            endState == input.expectedNumberOfStickers,
            "Expected to find \(input.expectedNumberOfStickers) but actually found \(endState).")

        let outputPersistedModels = try context.fetch(FetchDescriptor<ScannedBike>())
        let mostRecentInput = input.scannedBikesHistory
            .map(\.createdAt)
            .sorted(by: >)
            .prefix(upTo: input.expectedNumberOfStickers)

        let zipped = zip(mostRecentInput, outputPersistedModels)
        #expect(zipped.underestimatedCount == input.expectedNumberOfStickers)
        for (mostRecent, persisted) in zipped {
            #expect(mostRecent == persisted.createdAt)
        }
    }

    /// Verify manual deletion works correctly with date-based expiration only
    @Test(arguments: [25])
    func test_handleSwipeToDelete(stickerCount: Int) async throws {
        let testName = #function.trimmingCharacters(in: .alphanumerics.inverted)
        let config = ModelConfiguration(testName, isStoredInMemoryOnly: true)
        print("Config filename is \(config.name) out of \(config.id)")
        let container = try ModelContainer(for: ScannedBike.self, configurations: config)
        let context = container.mainContext
        let model = StickerCenter.ViewModel()

        var scannedBikesDescriptor = FetchDescriptor<ScannedBike>(
            predicate: #Predicate<ScannedBike> { _ in true })
        scannedBikesDescriptor.includePendingChanges = true

        let persistedStickers: [ScannedBike] = try (0..<stickerCount).map { mockScanIndex in
            let value = String(
                format: "bikeindex://https://bikeindex.org/bikes/scanned/SAM0000%02d", mockScanIndex
            )
            let sticker = try #require(ScannedBike(host: hostProvider, url: URL(string: value)))
            let savedSticker = try model.persist(context: context, sticker: sticker)
            #expect(savedSticker.persistentModelID.storeIdentifier != nil)

            let iteration_stickerCount = try context.fetchCount(scannedBikesDescriptor)
            #expect(iteration_stickerCount == mockScanIndex + 1)
            return savedSticker
        }

        let midway_stickerCount = try context.fetchCount(scannedBikesDescriptor)
        #expect(midway_stickerCount == stickerCount)
        #expect(persistedStickers.count == stickerCount)

        try model.delete(context: context, stickers: persistedStickers)
        let end_stickerCount = try context.fetchCount(scannedBikesDescriptor)
        #expect(0 == end_stickerCount)
    }
}
