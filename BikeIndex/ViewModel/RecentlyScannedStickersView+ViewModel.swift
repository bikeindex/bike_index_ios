//
//  RecentlyScannedStickersView+ViewModel.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import OSLog
import SwiftData
import SwiftUI

extension RecentlyScannedStickersView {
    @MainActor
    class ViewModel {
        static let limitOfMostRecent = 10

        func persist(context: ModelContext, sticker: ScannedBike) throws -> ScannedBike {
            // 1. Save the latest scanned bike sticker
            context.insert(sticker)
            try context.save()

            try cleanUpExpiredStickers(context: context)

            return sticker
        }

        private func cleanUpExpiredStickers(context: ModelContext) throws {
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
}
