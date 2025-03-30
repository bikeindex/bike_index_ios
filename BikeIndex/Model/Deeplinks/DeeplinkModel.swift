//
//  DeeplinkModel.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import Foundation

@Observable
final class DeeplinkModel: Identifiable {
    var scannedURL: URL?

    init(scannedURL: URL? = nil) {
        self.scannedURL = scannedURL
    }

    func scannedBike() -> ScannedBike? {
        ScannedBike(url: scannedURL)
    }
}

/// QR Code Identifiers are used in the format [A-Z]\d{5}
// TODO: (is that valid regex? check the Rails app)
/// Example: https://bikeindex.org/bikes/scanned/A40340
typealias QRIdentifier = String

@Observable
final class ScannedBike {
    var identifier: QRIdentifier

    var url: URL

    /// INPUTS:
    /// - HOST? to make sure the host matches client.configuration.host?????
    /// - bikes/scanned/:id
    /// - CHECK LAST PATH COMPONENT
    init?(url: URL?) {
        guard var url else { return nil }
        let lastPath1 = url.lastPathComponent
        url.deleteLastPathComponent()
        let lastPath2 = url.lastPathComponent
        url.deleteLastPathComponent()
        let lastpath3 = url.lastPathComponent

        guard lastPath2 == "scanned", lastpath3 == "bikes" else { return nil }
        self.identifier = lastPath1 // TODO: Parse this out with regex
        self.url = URL(string: "https://bikeindex.org/bikes/scanned/\(lastPath1)").unsafelyUnwrapped // TODO: Do this right
    }
}
