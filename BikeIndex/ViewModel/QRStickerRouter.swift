//
//  QRStickerRouter.swift
//  BikeIndex
//
//  Created by Jack on 6/5/26.
//

import Foundation
import OSLog
import SwiftUI

/// The goal of these changes is to:
/// 1. toggle display of the sticker center
/// 2. toggle display of a particular sticker deeplink -- adding to the navigation
///     hierarchy with the sticker center
/// Hmm.
/// Maybe we need to replace two Bools with 1 NavigationPath that we can just append
/// to.
/// Will that work pre/post authorization? Not certain.
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
