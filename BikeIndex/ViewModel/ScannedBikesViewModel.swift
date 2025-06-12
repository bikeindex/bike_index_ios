//
//  ScannedBikesViewModel.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import OSLog
import SwiftData
import SwiftUI

@MainActor @Observable
// TODO: Rename to database helper or something (or split into writer/deleter and the deleter can be namespaced to RecentlyScannedStickersView.ViewModel)
class ScannedBikesViewModel {
    static let limitOfMostRecent = 10

    let context: ModelContext
    let client: Client

    /// Refer to the last-known ``cleanUpExpiredStickers`` task
    /// to restart clean-up if multiple stickers are scanned in quick succession.
    private var cleanUpTask: Task<()?, any Error>? = nil

    // TODO: Change this to follow MainContentPage+ViewModel's approach of providing ModelContext and Client through function parameters instead of kept-references through init.
    init(context: ModelContext, client: Client) {
        self.context = context
        self.client = client
    }

    func persist(sticker: ScannedBike) throws -> ScannedBike {
        // 1. Save the latest scanned bike sticker
        context.insert(sticker)
        try context.save()

        let savedStickersCount = try context.fetchCount(FetchDescriptor<ScannedBike>())
        if savedStickersCount > Self.limitOfMostRecent {
            cleanUpTask?.cancel()
            cleanUpTask = Task { [weak self] in
                try await self?.cleanUpExpiredStickers()
            }
        }

        return sticker
    }

    // TODO: Consider removing the time interval
    private func cleanUpExpiredStickers() async throws {
        // 2. Find all known-good stickers that meet these conditions
        //      - scanned in the last 2 weeks
        //      - scanned in the 10-most-recent
        // Ex: The 11th sticker scan will be forgotten.
        // Ex: A sticker scanned 15 days ago will be forgotten.
        let twoWeeksAgo = Date().addingTimeInterval(-60 * 60 * 24 * 14)
        let bikesScannedInTheLastTwoWeeks = #Predicate<ScannedBike> { model in
            model.createdAt > twoWeeksAgo
        }

        var fetchDescriptor = FetchDescriptor<ScannedBike>(
            predicate: bikesScannedInTheLastTwoWeeks,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        fetchDescriptor.fetchLimit = 10

        // Cannot use context.fetchIdentifiers() _if_ the FetchDescriptor has a `sortBy` on a non-identifier field
        // because that field won't be available in the fetch operation.
        // So just fetch everything and then map on the persistentModelID.
        let tenMostRecentStickers = try context.fetch(fetchDescriptor).map(\.persistentModelID)

        // 3. Delete the rest
        try context.delete(
            model: ScannedBike.self,
            where: #Predicate<ScannedBike> { model in
                tenMostRecentStickers.contains(model.persistentModelID) == false
            })
    }

    /// Support deleting for manual removal
    func delete(stickers: [ScannedBike]) throws {
        try context.transaction {
            for sticker in stickers {
                context.delete(sticker)
            }
        }
    }
}
