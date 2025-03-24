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

    /// App settings
    case settings

    /// Register a bike that is with-owner
    case registerBike

    /// Register a bike that is stolen
    case lostBike

    /// Open Search URL
    case searchBikes
}
