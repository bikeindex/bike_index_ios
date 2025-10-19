//
//  BikeEntity.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import AppIntents
import SwiftData

/// App Intents-friendly version of the `Bike` model used in Siri and Shortcuts.
struct BikeEntity: AppEntity {
    static let defaultQuery = BikeQuery()

    var id: Int
    var title: String

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Bike")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}
