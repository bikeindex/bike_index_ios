//
//  AppIcon.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import UIKit

/// Represents preview icons from asset catalog for display in-app.
/// These asset catalog resources must append "-in-app" to load the resource.
/// Actual icons are in Icon Composer format for iOS 26.
enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case blueOnInverse = "Blue-on-inverse"
    case Grayscale = "Grayscale"
    case striped = "Striped"
    case pride = "Pride"
    #if DEBUG
    case doodle = "Doodle"
    #endif

    /// From iOS 18+ icon 'previews' must be in a regular image asset catalog, thus "-in-app".
    var id: String { rawValue + "-in-app" }

    /// Provide a name suitable for the Alternate App Icon API to ingest.
    /// This is not suitable for displaying a UIImage in-app
    var iconName: String? {
        switch self {
        case .primary:
            return nil
        default:
            return rawValue
        }
    }

    /// Provide a UIImage suitable for display in-app
    var image: UIImage {
        if let uiImage = UIImage(named: id) {
            return uiImage
        } else {
            // Fallback SF Symbol when an AppIcon cannot be loaded
            return UIImage(systemName: "questionmark.app.dashed")!
        }
    }

    /// User-facing description for each icon.
    var description: String {
        switch self {
        case .primary:
            return "Bike Index"
        case .blueOnInverse:
            return "Blue on inverse"
        case .Grayscale:
            return "Grayscale"
        case .striped:
            return "Striped"
        case .pride:
            return "Pride 🏳️‍🌈"
        #if DEBUG
        case .doodle:
            return "Jack's Doodle"
        #endif
        }
    }
}
