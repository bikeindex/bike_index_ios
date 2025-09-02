//
//  AlternateIconsModel.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import OSLog
import Observation
import UIKit

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
