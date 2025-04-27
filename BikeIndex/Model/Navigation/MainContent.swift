//
//  MainContent.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import Foundation

/// Top-level navigation options that are always available.
enum MainContent: Identifiable {
    var id: Self { self }

    /// General
    case settings
    case help

    /// Registration
    case registerBike
    case lostBike

    /// Search
    case searchBikes
}
