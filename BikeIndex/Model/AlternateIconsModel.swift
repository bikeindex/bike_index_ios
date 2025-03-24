//
//  AlternateIconsModel.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import OSLog
import Observation
import UIKit

/// Represents icons in Assets/AppIcons asset catalog.
/// For display in-app, 1) append "-in-app" and 2) see Assets/AppIcons-in-app catalog.
enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case blackOnWhite = "AppIcon-bow"
    case whiteOnBlack = "AppIcon-wob"
    case striped = "AppIcon-striped"
    case pride = "AppIcon-pride"
    #if DEBUG
    case doodle = "Doodle"
    #endif

    /// iOS 18 icons must be in a regular image asset catalog, thus "-in-app".
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
            return UIImage(systemName: "questionmark.app.dashed").unsafelyUnwrapped
        }
    }

    var description: String {
        switch self {
        case .primary:
            return "Default"
        case .blackOnWhite:
            return "Black on white"
        case .whiteOnBlack:
            return "White on black"
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

@MainActor @Observable
final class AlternateIconsModel {
    private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName,
            let appIcon = AppIcon(rawValue: iconName)
        {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    var hasAlternates: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    func update(icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        guard UIApplication.shared.alternateIconName != icon.iconName else {
            // No need to update since we're already using this icon.
            return
        }

        Task { @MainActor in
            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                // We're only logging the error here and not actively handling the app icon failure
                // since it's very unlikely to fail.
                Logger.views.error("Updating icon to \(String(describing: icon.id)) failed.")

                // Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}
