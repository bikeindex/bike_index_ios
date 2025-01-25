//
//  BicycleType.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

enum PropulsionType: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }

    case footPedal = "foot-pedal"
    case pedalAssist = "pedal-assist"
    case throttle = "throttle"
    case pedalAssistAndThrottle = "pedal-assist-and-throttle"
    case handPedal = "hand-pedal"
    case humanNotPedal = "human-not-pedal"

    var name: String {
        switch self {
        case .footPedal:
            return "Foot Pedal"

        case .pedalAssist:
            return "Pedal Assist"

        case .throttle:
            return "Electric Throttle"

        case .pedalAssistAndThrottle:
            return "Pedal Assist and Throttle"

        case .handPedal:
            return "Hand Cycle (hand pedal)"

        case .humanNotPedal:
            return "Human powered (not by pedals)"
        }
    }

}

/// Raw values correspond to the 'Slug' used in the API
enum BicycleType: String, Codable, CaseIterable, Identifiable {
    case bike = "bike"
    case tandem = "tandem"
    case unicycle = "unicycle"
    case tricycle = "tricycle"
    case stroller = "stroller"
    case recumbent = "recumbent"
    case trailer = "trailer"
    case wheelchair = "wheelchair"
    /// Cargo Bike (front storage)
    case cargo = "cargo"
    case tallBike = "tall-bike"
    case pennyFarthing = "penny-farthing"
    case cargoRear = "cargo-rear"
    case cargoTrike = "cargo-trike"
    case cargoTrikeRear = "cargo-trike-rear"
    case trailBehind = "trail-behind"
    case pediCab = "pedi-cab"
    case eScooter = "e-scooter"
    case personalMobility = "personal-mobility"
    case nonEScooter = "non-e-scooter"
    case nonESkateboard = "non-e-skateboard"

    var id: Self { self }

    /// Hm, the raw values may need to be changed to the bike_index.CycleType.NAMES values because those are sent by the API. https://github.com/bikeindex/bike_index/blob/main/app/models/cycle_type.rb
    /// That would make this name field obsolete
    var name: String {
        switch self {
        case .bike:
            return "Bike"
        case .tandem:
            return "Tandem"
        case .unicycle:
            return "Unicycle"
        case .tricycle:
            return "Tricycle"
        case .stroller:
            return "Stroller"
        case .recumbent:
            return "Recumbent"
        case .trailer:
            return "Bike Trailer"
        case .wheelchair:
            return "Wheelchair"
        case .cargo:
            return "Cargo Bike (front storage)"
        case .tallBike:
            return "Tall Bike"
        case .pennyFarthing:
            return "Penny Farthing"
        case .cargoRear:
            return "Cargo Bike (rear storage)"
        case .cargoTrike:
            return "Cargo Tricycle (front storage)"
        case .cargoTrikeRear:
            return "Cargo Tricycle (rear storage)"
        case .trailBehind:
            return "Trail behind (half bike)"
        case .pediCab:
            return "Pedi Cab (rickshaw)"
        case .eScooter:
            return "E-Scooter"
        case .personalMobility:
            return "E-Skateboard (E-Unicycle, Personal mobility device, etc)"
        case .nonEScooter:
            return "Scooter (not electric)"
        case .nonESkateboard:
            return "Skateboard (Not electric)"
        }
    }
}

extension BicycleType {
    /// Determine whether the user _can mark_ this bicycle/item type as electric motorized.
    var canBeElectric: Bool {
        switch self {
        case .bike,
            .tandem,
            .unicycle,
            .tricycle,
            .stroller,
            .recumbent,
            .trailer,
            .wheelchair,
            .cargo,
            .tallBike,
            .pennyFarthing,
            .cargoRear,
            .cargoTrike,
            .cargoTrikeRear:
            return true
        case .trailBehind:
            return false
        case .pediCab:
            return true
        case .eScooter:
            return true  // FIXED true
        case .personalMobility:
            return true  // FIXED true
        case .nonEScooter:
            return false
        case .nonESkateboard:
            return false
        }
    }

    /// Determine whether the user _can mark_ this bicycle/item type as having throttle, pedal assist (separate fields).
    var pedalAssistAndThrottle: Bool {
        switch self {
        case .bike,
            .tandem,
            .unicycle,
            .tricycle:
            return true
        case .stroller:
            return false
        case .recumbent:
            return true
        case .trailer,
            .wheelchair:
            return false
        case .cargo,
            .tallBike,
            .pennyFarthing,
            .cargoRear,
            .cargoTrike,
            .cargoTrikeRear:
            return true
        case .trailBehind:
            return false
        case .pediCab:
            return true
        case .eScooter:
            return false
        case .personalMobility:
            return false
        case .nonEScooter:
            return false
        case .nonESkateboard:
            return false
        }
    }
}
