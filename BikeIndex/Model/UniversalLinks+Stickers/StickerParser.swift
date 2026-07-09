//
//  StickerParser.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import Foundation
import HoneybadgerSwift
import OSLog

/// Inputs:
///  - Deeplinks to `bikeindex://`
///  - Sticker codes, such as `A 403 40`
final class StickerParser: Identifiable {
    private let hostProvider: HostProvider

    /// Only one ``DeeplinkManager`` should be instantiated.
    init(host: HostProvider) {
        self.hostProvider = host
    }

    /// Parse Deeplinks / Universal Links for QR Stickers
    /// e.g. external camera scans or Safari deeplinks
    func scan(url: URL?) -> ScannedSticker? {
        guard let scannedBike = ScannedSticker(host: hostProvider, url: url) else {
            Logger.deeplinks.error(
                "Failed to scan QR sticker from universal link \(String(describing: url), privacy: .auto)"
            )
            return nil
        }
        return scannedBike
    }

    /// Parse in-app camera scans
    func parse(code: String) -> ScannedSticker? {
        guard
            let scannedBike = ScannedSticker(
                host: hostProvider, url: URL(string: code))
        else {
            Honeybadger.notify(
                errorString: "Failed to scan QR sticker from camera code",
                context: [
                    Honeybadger.ContextKey.qrSticker.rawValue: code
                ])
            Logger.deeplinks.error("Failed to scan QR sticker from camera code \(code)")
            return nil
        }

        return scannedBike
    }
}
