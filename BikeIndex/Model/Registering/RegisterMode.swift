//
//  RegisterMode.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

enum RegisterMode {
    case myOwnBike
    case myStolenBike

    /// User-facing title for what this mode will do
    var title: String {
        switch self {
        case .myOwnBike:
            "Enter Bike Details"
        case .myStolenBike:
            "Enter Stolen Bike Details"
        }
    }
}
