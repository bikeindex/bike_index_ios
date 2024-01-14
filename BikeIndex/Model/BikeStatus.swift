//
//  BikeStatus.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

enum BikeStatus: String, Codable {
    case withOwner = "with owner"
    case found
    case stolen
    case abandoned
    case impounded
    case unregisteredParkingNotification = "unregistered parking notification"
}
