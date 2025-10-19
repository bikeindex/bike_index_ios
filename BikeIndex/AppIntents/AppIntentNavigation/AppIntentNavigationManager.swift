//
//  AppIntentNavigationManager.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import SwiftUI

/// Handles navigation triggered by App Intents (e.g. Siri or Shortcuts).
/// When a bike is selected, this sets `presentedItem` to show a sheet in `MainContentPage`.
@MainActor @Observable
final class AppIntentNavigationManager {
    static let shared = AppIntentNavigationManager()
    var presentedItem: AppIntentSheetItem?
}
