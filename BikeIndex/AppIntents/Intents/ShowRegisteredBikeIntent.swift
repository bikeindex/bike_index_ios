//
//  ShowRegisteredBikeIntent.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import AppIntents

/// App Intent that opens the app and displays details for a specific bike.
/// Triggered via Siri or Shortcuts.
struct ShowRegisteredBikeIntent: AppIntent {

    /// Title shown in Shortcuts and Siri.
    static let title: LocalizedStringResource = "Open Bike Details"

    /// Description shown when viewing this shortcut’s details.
    static let description = IntentDescription(
        "Open the app and launch details of a registered bike.")

    /// Ensures the main app launches when this intent runs.
    static let openAppWhenRun = true

    /// The bike the user selects in Siri or Shortcuts.
    @Parameter(title: "Which Bike?")
    var bike: BikeEntity

    /// Called when the intent executes. Updates the navigation manager
    /// with the selected bike, triggering the sheet presentation in the app.
    @MainActor
    func perform() async throws -> some IntentResult {
        AppIntentNavigationManager.shared.presentedItem = .init(bikeIdentifier: bike.id)
        return .result()
    }
}
