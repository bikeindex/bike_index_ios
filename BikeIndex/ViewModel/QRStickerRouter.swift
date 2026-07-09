//
//  QRStickerRouter.swift
//  BikeIndex
//
//  Created by Jack on 6/5/26.
//

import Foundation
import OSLog
import SwiftUI

/// QRSticker control controls the navigation of the Sticker Center
/// 1. The first thing it controls is toggling display of the sticker center
/// 2. The second facet is wehter a particular sticker deeplink is displayed
///     adding the scanned sticker model to the navigation path to jump to a
///     scan.
@MainActor @Observable
class QRStickerRouter {
    var displayStickerCenter: Bool = false

    var showHowToPage = false

    var path: NavigationPath = NavigationPath()

    /// Keep only 1 active QR scanned bike for immediate display in the UI.
    /// This is ephemeral and does not care about scan history.
    private var scannedBike: ScannedBike?

    // MARK: Update Navigation

    func scanUniversalLink(_ scan: ScannedBike) {
        scannedBike = scan
        displayStickerCenter = true
        path.append(scan)
    }

    func closeStickerCenter() {
        Logger.camera.info("[QRStickerRouter.closeStickerCenter]")
        scannedBike = nil
        path = NavigationPath()
    }
}
