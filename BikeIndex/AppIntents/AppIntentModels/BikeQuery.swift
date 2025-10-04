//
//  BikeQuery.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import AppIntents
import SwiftData

/// Provides App Intents with access to `Bike` data stored in SwiftData.
/// Responsible for fetching and converting models into `BikeEntity` representations.
@MainActor
struct BikeQuery: EntityQuery {

    @Dependency(key: "ModelContainer")
    private var modelContainer: ModelContainer

    private var context: ModelContext {
        ModelContext(modelContainer)
    }

    /// Fetches specific `Bike` objects matching the given identifiers,
    /// and maps them into `BikeEntity` types for use in App Intents (e.g. during perform).
    func entities(for identifiers: [Int]) async throws -> [BikeEntity] {
        let descriptor = FetchDescriptor<Bike>(predicate: #Predicate { identifiers.contains($0.identifier) })
        let results = try context.fetch(descriptor)

        return results.map {
            BikeEntity(id: $0.identifier,
                       title: "\($0.frameColorPrimary.displayValue) \($0.manufacturerName)")
        }
    }

    /// Returns a small set of recent or commonly used bikes as `BikeEntity` suggestions
    /// for display in App Intents pickers (such as Siri or Shortcuts).
    func suggestedEntities() async throws -> [BikeEntity] {
        var descriptor = FetchDescriptor<Bike>(sortBy: [SortDescriptor(\.identifier)])
        descriptor.fetchLimit = 10

        let results = try context.fetch(descriptor)

        return results.map {
            BikeEntity(id: $0.identifier,
                       title: "\($0.frameColorPrimary.displayValue) \($0.manufacturerName)")
        }
    }
}
