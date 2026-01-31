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

extension FrameColor {
    var prettyColor: Color? {
        switch self {
        case .black:
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) // #000
        case .blue:
            Color(#colorLiteral(red: 0.22, green: 0.431, blue: 0.824, alpha: 1)) // #386ed2
        case .brown:
            Color(#colorLiteral(red: 0.451, green: 0.29, blue: 0.133, alpha: 1)) // #734a22
        case .green:
            Color(#colorLiteral(red: 0.106, green: 0.631, blue: 0, alpha: 1)) // #1ba100<#code#>
        case .orange:
            Color(#colorLiteral(red: 1, green: 0.553, blue: 0.114, alpha: 1)) // #ff8d1d
        case .pink:
            Color(#colorLiteral(red: 1, green: 0.49, blue: 0.992, alpha: 1)) // #ff7dfd
        case .purple:
            Color(#colorLiteral(red: 0.655, green: 0.271, blue: 0.753, alpha: 1)) // #a745c0
        case .red:
            Color(#colorLiteral(red: 0.925, green: 0.075, blue: 0.075, alpha: 1)) // #ec1313
        case .bareMetal:
            // NOTE: normally nil!
            Color(#colorLiteral(red: 0.69, green: 0.69, blue: 0.69, alpha: 1)) // #b0b0b0
        case .covered:
            nil
        case .teal:
            Color(#colorLiteral(red: 0.231, green: 0.929, blue: 0.906, alpha: 1)) // #3bede7
        case .white:
            Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // #fff
        case .yellow:
            Color(#colorLiteral(red: 1, green: 0.957, blue: 0.294, alpha: 1)) // #fff44b
        }
    }
}
