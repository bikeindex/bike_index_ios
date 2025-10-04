//
//  BikeIndexShortcutsProvider.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import AppIntents

/// Defines the App Shortcut for viewing a bike, including the phrases
/// Siri can use to trigger the shortcut.
struct BikeIndexShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ShowRegisteredBikeIntent(),
                phrases: [ "View bike in \(.applicationName)"],
                shortTitle: "Launch Bike Details",
                systemImageName: "bicycle")
    }
}
