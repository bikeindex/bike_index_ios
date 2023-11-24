//
//  FrameColor.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

enum FrameColor: String, Codable, CaseIterable, Identifiable, Equatable {
    case black
    case blue
    case brown
    case green
    case orange
    case pink
    case purple
    case red
    /// includes Silver and Gray!
    case bareMetal = "silver, gray or bare metal"
    /// covered by stickers, tape, or other cover-ups
    case covered = "stickers tape or other cover-up"
    case teal
    case white
    /// includes Gold
    case yellow = "yellow or gold"

    var id: Self { self }

    var displayValue: String {
        switch self {
        case .black: return "Black"
        case .blue: return "Blue"
        case .brown: return "Brown"
        case .green: return "Green"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .red: return "Red"
        case .teal: return "Teal"
        case .white: return "White"
        case .bareMetal:
            return "Silver, Gray, or Bare Metal"
        case .covered:
            return "Stickers, tape, or other cover-up"
        case .yellow:
            return "Yellow or Gold"
        default:
            return self.rawValue.capitalized
        }
    }

    /// Provide a default value to the UI when a selection has not yet been made.
    static var defaultColor: Self {
        .black
    }
}

extension [FrameColor] {
    var primary: FrameColor? {
        get {
            if self.count < 1 {
                return nil
            }
            return self[0]
        }
        set {
            if let newValue {
                insert(newValue, at: 0)
            }
        }
    }

    var secondary: FrameColor? {
        get {
            if count > 1 {
                return self[1]
            } else {
                return nil
            }
        }
        set {
            if let newValue {
                if count == 0 {
                    insert(newValue, at: 1)
                } else {
                    self[1] = newValue
                }
            } else {
                remove(at: 1)
            }
        }
    }

    var tertiary: FrameColor? {
        get {
            if count < 3 {
                return nil
            }
            return self[2]
        }
        set {
            if let newValue {
                if count == 2 {
                    append(newValue)
                } else {
                    self[2] = newValue
                }
            } else {
                remove(at: 2)
            }
        }
    }
}
