//
//  AppIntentSheetItem.swift
//  BikeIndex
//
//  Created by Matt Heaney on 18/10/2025.
//

import SwiftUI

/// Represents the bike selected from an App Intent to show in a sheet.
struct AppIntentSheetItem: Identifiable, Equatable {
    let bikeIdentifier: Int
    var id: Int { bikeIdentifier }
}
