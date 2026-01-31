//
//  FrameColor.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI

/// NOTE: **Reading** FrameColor from the API is in title-case.
/// **Writing** FrameColor to the API must be in lower-case.
/// Discussion: https://github.com/bikeindex/bike_index/issues/2524
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

    var id: String { rawValue }

    var displayValue: String { rawValue }

    /// Provide a default value to the UI when a selection has not yet been made.
    static var defaultColor: Self { .black }

    /// All frame colors ordered in typical ROYGBIV rainbow order followed by special material colors
    static let allCases: [FrameColor] = [
        .red, .pink, .orange, .yellow, .green, .teal, .blue, .purple, .brown, .black, .white,
        .bareMetal, .covered,
    ]

    /// A `true` value Indicates that this color is displayed with a special View (such as a gradient)
    /// or a `false` value indicates that this color can be converted to a ``SwiftUICore/Color``
    var textured: Bool {
        switch self {
        case .bareMetal, .covered:
            true
        default:
            false
        }
    }
}

extension FrameColor {
    var color: Color? {
        switch self {
        case .bareMetal, .covered:
            nil
        case .black:
            // slightly lighter than pure black for display
            Color(white: 0.1)
        case .blue:
            .blue
        case .brown:
            .brown
        case .green:
            .green
        case .orange:
            .orange
        case .pink:
            .pink
        case .purple:
            .purple
        case .red:
            .red
        case .teal:
            .teal
        case .white:
            // Slightly darker than pure white for display
            Color(white: 0.9)
        case .yellow:
            .yellow
        }
    }
}
