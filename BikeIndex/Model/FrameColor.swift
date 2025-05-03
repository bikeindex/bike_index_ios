//
//  FrameColor.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

/// NOTE: **Reading** FrameColor from the API is in title-case.
/// **Writing** FrameColor to the API must be in lower-case.
enum FrameColor: String, Codable, CaseIterable, Identifiable, Equatable {
    case black = "Black"
    case blue = "Blue"
    case brown = "Brown"
    case green = "Green"
    case orange = "Orange"
    case pink = "Pink"
    case purple = "Purple"
    case red = "Red"
    /// includes Silver and Gray!
    case bareMetal = "Silver, gray or bare metal"
    /// covered by stickers, tape, or other cover-ups
    case covered = "Stickers tape or other cover-up"
    case teal = "Teal"
    case white = "White"
    /// includes Gold
    case yellow = "Yellow or gold"

    // MARK: -

    var id: Self { self }

    var displayValue: String { rawValue }

    /// Provide a default value to the UI when a selection has not yet been made.
    static var defaultColor: Self { .black }
}
