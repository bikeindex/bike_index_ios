//
//  AppIcon.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import SwiftUI
import UIKit

/// Represents preview icons from asset catalog for display in-app.
/// These asset catalog resources must append "-in-app" to load the resource.
/// Actual icons are in Icon Composer format for iOS 26.
enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case blue = "Blue"
    case grayscale = "Grayscale"
    case navy = "Navy"
    case striped = "Striped"
    case pride = "Pride"

    /// From iOS 18+ icon 'previews' must be in a regular image asset catalog, thus "-in-app".
    /// See Assets.xcassets
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
        case .blue:
            return "Blue"
        case .grayscale:
            return "Grayscale"
        case .navy:
            return "Navy"
        case .striped:
            return "Striped"
        case .pride:
            return "Pride 🏳️‍🌈"
        }
    }
}

// Validates Views with UIImages (without using models)
#Preview("App Icon Direct UIImage Access") {
    VStack {
        Form {
            Section {
                Image(uiImage: UIImage(named: "AppIcon-in-app")!)
                    .appIcon(scale: .large)

                Label(
                    title: { Text("App Icon") },
                    icon: {
                        Image(uiImage: UIImage(named: "AppIcon-in-app")!)
                            .appIcon(scale: .small)
                    }
                )
            }
        }
    }
}
