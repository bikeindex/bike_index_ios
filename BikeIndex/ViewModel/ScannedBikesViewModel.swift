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
struct ScannedBikesViewModel {
    let context: ModelContext
    let client: Client

    init(context: ModelContext, client: Client) {
        self.context = context
        self.client = client
    }

    func persist(sticker: ScannedBike) throws {
        // 1. Save the latest scanned bike sticker
        context.insert(sticker)
        try context.save()

        // 2. Purge any sticker outside of:
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
            sortBy: [SortDescriptor(\.createdAt, order: .forward)])

        fetchDescriptor.fetchLimit = 10
        // Cannot use fetchIdentifiers _if_ the FetchDescriptor has a `sortBy` on a non-identifier field.
        let tenMostRecentStickers = try context.fetch(fetchDescriptor)
            .map(\.persistentModelID)

        try context.delete(
            model: ScannedBike.self,
            where: #Predicate<ScannedBike> { model in
                tenMostRecentStickers.contains(model.persistentModelID) == false
            })
    }
}
