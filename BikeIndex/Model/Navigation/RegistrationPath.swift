//
//  RegistrationPath.swift
//  BikeIndex
//
//  Created by Jack on 12/27/23.
//

import SwiftUI
import Observation

/// https://bikeindex.org/choose_registration
enum RegistrationPath: String, Hashable, Codable {
    // Entering bike registration
    case ownBike
    case knownStolen // status = stolen
    case foundAbandoned // status = impounded

    var showStolenRecord: Bool {
        self == .knownStolen || self == .foundAbandoned
    }
}
