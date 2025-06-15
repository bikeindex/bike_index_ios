//
//  ScannedBikesViewModel.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import OSLog
import SwiftData
import SwiftUI

@MainActor
class ScannedBikesViewModel {
    static let limitOfMostRecent = 10

    func persist(context: ModelContext, sticker: ScannedBike) throws -> ScannedBike {
        // 1. Save the latest scanned bike sticker
        context.insert(sticker)
        try context.save()

        try cleanUpExpiredStickers(context: context)

        return sticker
    }

    // TODO: Consider removing the time interval
    private func cleanUpExpiredStickers(context: ModelContext) throws {
        // 2. Find all known-good stickers that meet these conditions
        //      - scanned in the last 2 weeks
        //      - scanned in the 10-most-recent
        // Ex: The 11th sticker scan will be forgotten.
        // Ex: A sticker scanned 15 days ago will be forgotten.
        var fetchDescriptor = FetchDescriptor<ScannedBike>(
            predicate: #Predicate<ScannedBike> { _ in true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        fetchDescriptor.fetchLimit = Self.limitOfMostRecent

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
    func delete(context: ModelContext, stickers: [ScannedBike]) throws {
        try context.transaction {
            for sticker in stickers {
                context.delete(sticker)
            }
        }
    }
}
