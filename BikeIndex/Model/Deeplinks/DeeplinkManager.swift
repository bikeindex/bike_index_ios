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

    /// Only one ``DeeplinkManager`` should be instantiated.
    init(host: HostProvider) {
        self.hostProvider = host
    }

    /// Every URL scan should go through this function
    func scan(url: URL?) {
        if let scannedBike = ScannedBike(host: hostProvider, url: url) {
            self.scannedBike = scannedBike
        }
    }
}
