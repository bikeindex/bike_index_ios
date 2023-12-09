//
//  AlternateIconsModel.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import Observation
import OSLog
import UIKit

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case blackOnWhite = "AppIcon-bow"
    case whiteOnBlack = "AppIcon-wob"
    case striped = "AppIcon-striped"
    #if DEBUG
    case doodle = "Doodle"
    #endif

    var id: String { rawValue }

    var iconName: String? {
        switch self {
        case .primary:
            return nil
        default:
            return rawValue
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
        #if DEBUG
        case .doodle:
            return "Jack's Doodle"
        #endif
        }
    }
}


@Observable final class AlternateIconsModel {
    private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName, 
            let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    var hasAlternates: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    /// Fallback SF Symbol when an AppIcon cannot be loaded
    var absentIcon: String {
        "questionmark.app.dashed"
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
