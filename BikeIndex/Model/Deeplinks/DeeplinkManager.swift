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
    /// Keep only 1 active QR scanned bike for immediate display in the UI.
    /// This is forgetful and does not care about scan history.
    var scannedBike: ScannedBike?

    /// Only one ``DeeplinkManager`` should be instantiated.
    init(host: HostProvider) {
        self.hostProvider = host
    }

    /// Every URL scan should go through this function
    func scan(url: URL?) -> DeeplinkResult? {
        if let scannedBike = ScannedBike(host: hostProvider, url: url) {
            self.scannedBike = scannedBike
            return DeeplinkResult(scannedBike: scannedBike)
        } else {
            return nil
        }
    }
}

struct DeeplinkResult {
    let scannedBike: ScannedBike?
}
