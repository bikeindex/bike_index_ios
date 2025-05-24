//
//  ScannedBike.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import Foundation
import SwiftData

@Model
class ScannedBike: Equatable, Identifiable {
    var id: URL { url }

    /// QR Code Identifiers are used in the format [A-Z]\d{5}
    /// Example: https://bikeindex.org/bikes/scanned/A40340
    var sticker: String

    var url: URL

    var createdAt: Date

    /// Designated initializer only for SwiftData.
    init(sticker: String, url: URL, createdAt: Date = Date()) {
        self.sticker = sticker
        self.url = url
        self.createdAt = createdAt
    }
}

extension ScannedBike {
    /// Try to initialize a ScannedBike from a sticker.
    /// URLs will be bikes/scanned/:id and _may_ start with bikeindex:// (this is useful for development and testing).
    /// NOTE: Deeplinks will remove the second `:` from `bikeindex://https://bikeindex...`
    /// - Parameters:
    ///   - host: Configured host from xcconfig project config that determines the base URL for all API requests. Usually bikeindex.org/
    ///   - inputUrl: The scanned bike sticker, expected in formats
    ///     - bikeindex://{host}/bikes/scanned/:id
    ///     - {host}/bikes/scanned/:id
    convenience init?(host provider: HostProvider, url inputUrl: URL?) {
        guard let inputUrl else { return nil }
        let inputPrefixTrimmed = String(inputUrl.absoluteString.trimmingPrefix("bikeindex://"))
        let inputCorrectedBase = inputPrefixTrimmed.replacingOccurrences(
            of: "https//", with: "http://")

        guard let components = URLComponents(string: inputCorrectedBase),
            let url = components.url,
            components.host == provider.host.host()
        else {
            print("ScannedBike.init failed on nil URL input. Found \(inputCorrectedBase)")
            return nil
        }

        let identifier = url.lastPathComponent

        let givenPathComponents = url.pathComponents
        let expectedPathComponents = ["/", "bikes", "scanned", identifier]

        guard givenPathComponents == expectedPathComponents else {
            print("ScannedBike.init failed to find bikes/scanned/:id")
            return nil
        }

        self.init(sticker: identifier, url: url)
    }
}
