//
//  DeeplinkModel.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import Foundation

@Observable
final class DeeplinkManager: Identifiable {    
    var scannedBike: ScannedBike?

    init(scannedURL: URL? = nil) {
        self.scannedBike = ScannedBike(url: scannedURL)
    }
}

struct ScannedBike: Equatable, Identifiable {
    var id: URL { url }

    var sticker: Sticker

    var url: URL
}

extension ScannedBike {
    /// INPUTS:
    /// - TODO: HOST? to make sure the host matches client.configuration.host
    /// - bikes/scanned/:id
    /// - CHECK LAST PATH COMPONENT
    init?(url: URL?) {
        guard var url else {
            print("ScannedBike.init failed on nil URL input")
            return nil
        }
        // TODO: Parse this out with regex
        self.sticker = Sticker(url: url)

        // TODO: During development universal links have a bikeindex:// prefix.
        // Reimplement this without the prefix when validation is closer.
        let lastPath1 = url.lastPathComponent
        url.deleteLastPathComponent()
        let lastPath2 = url.lastPathComponent
        url.deleteLastPathComponent()
        let lastpath3 = url.lastPathComponent

        guard lastPath2 == "scanned", lastpath3 == "bikes" else {
            print("ScannedBike.init failed to find bikes/scanned/:id")
            return nil
        }
        self.url = URL(string: "https://bikeindex.org/bikes/scanned/\(lastPath1)").unsafelyUnwrapped
    }
}

/// QR Code Identifiers are used in the format [A-Z]\d{5}
/// Example: https://bikeindex.org/bikes/scanned/A40340
struct Sticker: Equatable {
    var identifier: String

    init(url: URL) {
        identifier = url.lastPathComponent
    }
}
