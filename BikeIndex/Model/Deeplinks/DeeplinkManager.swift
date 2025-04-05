//
//  DeeplinkModel.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import Foundation

@Observable
final class DeeplinkManager: Identifiable {
    let hostProvider: HostProvider
    var scannedBike: ScannedBike?

    init(host: HostProvider, scannedURL: URL? = nil) {
        self.hostProvider = host
        self.scannedBike = ScannedBike(host: host,
                                       url: scannedURL)
    }
}

struct ScannedBike: Equatable, Identifiable {
    var id: URL { url }

    var sticker: Sticker

    var url: URL
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
    init?(host provider: HostProvider, url inputUrl: URL?) {
        guard let inputUrl else { return nil }
        let inputPrefixTrimmed = String(inputUrl.absoluteString.trimmingPrefix("bikeindex://"))
        let inputCorrectedBase = inputPrefixTrimmed.replacingOccurrences(of: "https//", with: "http://")

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

        self.url = url
        self.sticker = Sticker(identifier: identifier)

    }
}

/// QR Code Identifiers are used in the format [A-Z]\d{5}
/// Example: https://bikeindex.org/bikes/scanned/A40340
struct Sticker: Equatable {
    var identifier: String
}
