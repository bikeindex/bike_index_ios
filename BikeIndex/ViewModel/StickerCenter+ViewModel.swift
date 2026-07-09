//
//  StickerCenter+ViewModel.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import OSLog
import SwiftData
import SwiftUI

extension StickerCenter {
    /// Data marshaller for persistence operations
    class ViewModel {

        /// Save the latest scanned bike sticker, and start a clean-up of expired stickers
        func persist(context: ModelContext, sticker: ScannedBike) throws -> ScannedBike {
            context.insert(sticker)

            try context.save()
            try cleanUpExpiredStickers(context: context)

            Logger.model.debug(
                "Persisted sticker \(sticker.sticker)-\(String(describing: sticker.persistentModelID))"
            )

            return sticker
        }

        /// Find and purge all stickers scanned older than 2 weeks ago.
        /// There is no limit to the number of scanned stickers within the allowed date range.
        /// Ex: A sticker scanned 15 days ago will be dropped.
        func cleanUpExpiredStickers(context: ModelContext) throws {
            // Lock the date threshold once at function entry so both Parts 1 & 2 use the same reference point.
            let twoWeeksAgo = Date().addingTimeInterval(-60 * 60 * 24 * 14)

            // # Part 1: Purge all stickers older than 2 weeks ago
            // createdAt must always be checked, stickers could expire at any time.
            let bikesScannedOlderThan2Weeks = #Predicate<ScannedBike> { model in
                model.createdAt < twoWeeksAgo
            }

            // Delete all models older than 2 weeks ago
            try context.delete(
                model: ScannedBike.self,
                where: bikesScannedOlderThan2Weeks)
            // Log stickers deleted due to the date
            let dateDeletedModels = context.deletedModelsArray.compactMap { $0 as? ScannedBike }
            if dateDeletedModels.isEmpty == false {
                let dateDeletedStickers = dateDeletedModels.map { ($0.sticker, $0.createdAt) }
                Logger.model.debug(
                    "\(#function) deleted \(dateDeletedStickers.count) stickers based on scan date: \(dateDeletedStickers)"
                )
            } else {
                Logger.model.debug("\(#function) all stickers within scan date limits")
            }
        }

        /// Support manual 'Swipe to delete'
        func delete(context: ModelContext, stickers: [ScannedBike]) throws {
            let deletedStickers = stickers.map(\.sticker)
            try context.transaction {
                for sticker in stickers {
                    context.delete(sticker)
                }
            }
            Logger.model.debug("Deleted stickers \(deletedStickers)")
        }
    }
}
