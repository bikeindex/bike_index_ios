//
//  FrameColor.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

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
    case yellow = "Yellow or Gold"

    var id: Self { self }

    var displayValue: String {
        switch self {
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
    // TODO: Just rip all this out, replace it with three regular fields, and perform array-marshalling at the network layer
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
