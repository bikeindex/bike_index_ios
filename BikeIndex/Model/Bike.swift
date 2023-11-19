//
//  Bike.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData
import MapKit

/*
 https://bikeindex.org:443/api/v3/me/bikes?access_token=fQPgqWD7Lrtaz9OhCXF1Zw9jAsPjHoHeaSQU1Wfo-kI

 {
   "bike": {
     "date_stolen": 1376719200,
     "description": "26\" Giant Trance X  ",
     "frame_colors": [
       "Green"
     ],
     "frame_model": "Trance X",
     "id": 20348,
     "is_stock_img": false,
     "large_img": null,
     "location_found": null,
     "manufacturer_name": "Giant",
     "external_id": null,
     "registry_name": null,
     "registry_url": null,
     "serial": "GS020355",
     "status": "stolen",
     "stolen": true,
     "stolen_coordinates": [
       45.53,
       -122.69
     ],
     "stolen_location": "Portland, OR 97209, US",
     "thumb": null,
     "title": "2012 Giant Trance X",
     "url": "https://bikeindex.org/bikes/20348",
     "year": 2012,
     "propulsion_type_slug": "foot-pedal",
     "cycle_type_slug": "bike",
     "registration_created_at": 1377151200,
     "registration_updated_at": 1585269739,
     "api_url": "https://bikeindex.org/api/v1/bikes/20348",
     "manufacturer_id": 153,
     "paint_description": null,
     "name": null,
     "frame_size": null,
     "rear_tire_narrow": true,
     "front_tire_narrow": null,
     "type_of_cycle": "Bike",
     "test_bike": false,
     "rear_wheel_size_iso_bsd": null,
     "front_wheel_size_iso_bsd": null,
     "handlebar_type_slug": null,
     "frame_material_slug": null,
     "front_gear_type_slug": null,
     "rear_gear_type_slug": null,
     "extra_registration_number": null,
     "additional_registration": null,
     "stolen_record": {
       "date_stolen": 1376719200,
       "location": "Portland, OR 97209, US",
       "latitude": 45.53,
       "longitude": -122.69,
       "theft_description": "Bike rack Reward: Tbd",
       "locking_description": null,
       "lock_defeat_description": null,
       "police_report_number": "1368801",
       "police_report_department": "Portland",
       "created_at": 1402778082,
       "create_open311": false,
       "id": 16690
     },
     "public_images": [],
     "components": []
   }
 }
 */

/// Returned by https://bikeindex.org:443/api/v3/bikes/{id}
final class ResponseBike: Decodable {
    var bike: Bike

    enum CodingKeys: String, CodingKey {
        case bike
    }
}

/// Returned by global search https://bikeindex.org:443/api/v3/search
final class ResponseBikes: Decodable {
    var bikes: [Bike]

    enum CodingKeys: String, CodingKey {
        case bikes
    }
}

@Model final class Bike: Decodable {

    @Attribute(.unique) var identifier: Int
    var bikeDescription: String?
    var frameModel: String?
    var frameColors: [FrameColor]
    var manufacturerName: String
    // var manufacturerId: ManufacturerId // TODO: How are we going to query manufacturers?
    var year: Int?
    var typeOfCycle: BicycleType

    /// Nil if the serial number is absent
    var serial: String?

    var status: BikeStatus

    // 2D coordinate is a struct
    // Persistent model requires a class/object
    @Transient var stolenCoordinates: CLLocation? {
        get {
            CLLocation(latitude: stolenCoordinateLatitude, longitude: stolenCoordinateLongitude)
        }
        set {
            if let newValue {
                stolenCoordinateLatitude = newValue.coordinate.latitude
                stolenCoordinateLongitude = newValue.coordinate.longitude
            } else {
                stolenCoordinateLatitude = .nan
                stolenCoordinateLongitude = .nan
            }
        }
    }
    private var stolenCoordinateLatitude: CLLocationDegrees
    private var stolenCoordinateLongitude: CLLocationDegrees
    var stolenLocation: String?
    var dateStolen: Date?

    var thumb: URL?
    var url: URL
    var apiUrl: URL?
    var publicImages: [String]

    /// NOT WRITTEN TO API
    var currentOwnerId: Int = -1

    struct Constants {
        /// The range of supported years for Bike models
        static let yearRange = 1900..<2100
        /// The range of **displayable** years for Bike models
        static let displayableYearRange = 1900..<2024
        /// Only 3 frame colors are allowed.
        static let maxFrameColorsCount = 3
    }

    init() {
        identifier = 0
        bikeDescription = ""
        frameModel = ""
        frameColors = [FrameColor.defaultColor]
        manufacturerName = ""
        serial = ""
        status = .withOwner
        typeOfCycle = .bike

        stolenCoordinateLatitude = 0
        stolenCoordinateLongitude = 0
        stolenLocation = ""
        dateStolen = Date.distantFuture
        let defaultUrl = URL(string: "about:blank").unsafelyUnwrapped
        url = defaultUrl
        apiUrl = defaultUrl
        publicImages = []
    }

    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case bikeDescription = "description"
        case frameModel = "frame_model"
        case frameColors = "frame_colors"
        case cycleTypeSlug = "cycle_type_slug"
        case manufacturerName = "manufacturer_name"
        case serial
        case status
        case stolenCoordinates = "stolen_coordinates"
        case stolenLocation = "stolen_location"
        case dateStolen = "date_stolen"
        case url
        case apiUrl = "api_url"
        case publicImages = "public_images"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(Int.self, forKey: .identifier)
        bikeDescription = try container.decodeIfPresent(String.self, forKey: .bikeDescription)
        frameModel = try container.decodeIfPresent(String.self, forKey: .frameModel)
        frameColors = try container.decode([FrameColor].self, forKey: .frameColors)
        manufacturerName = try container.decode(String.self, forKey: .manufacturerName)
        serial = try container.decode(String.self, forKey: .serial)
        status = try container.decode(BikeStatus.self, forKey: .status)
        typeOfCycle = try container.decode(BicycleType.self, forKey: .cycleTypeSlug)

        let rawCoordinates = try container.decodeIfPresent([CLLocationDegrees].self, forKey: .stolenCoordinates)
        if let rawCoordinates,
            rawCoordinates.count == 2,
            let lat = rawCoordinates.first,
            let lon = rawCoordinates.last {
            stolenCoordinateLatitude = lat
            stolenCoordinateLongitude = lon
        } else {
            stolenCoordinateLatitude = CLLocationDegrees.nan
            stolenCoordinateLongitude = CLLocationDegrees.nan
        }

        stolenLocation = try container.decodeIfPresent(String.self, forKey: .stolenLocation)

        if let dateStolenTimeInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .dateStolen) {
            dateStolen = Date(timeIntervalSince1970: dateStolenTimeInterval)
        }

        let rawUrl = try container.decode(String.self, forKey: .url)
        if let parsedUrl = URL(string: rawUrl) {
            url = parsedUrl
        } else {
            url = URL(string: "about:blank").unsafelyUnwrapped
        }

        let rawApiUrl = try container.decodeIfPresent(String.self, forKey: .apiUrl)
        if let rawApiUrl, let parsedApiUrl = URL(string: rawApiUrl) {
            apiUrl = parsedApiUrl
        } else {
            apiUrl = URL(string: "about:blank").unsafelyUnwrapped
        }

        publicImages = try container.decodeIfPresent([String].self, forKey: .publicImages) ?? []
    }
}

extension Bike {
    func addFrameColor() {
        guard frameColors.count < Constants.maxFrameColorsCount else {
            return
        }

        frameColors.append(FrameColor.defaultColor)
    }

    func removeFrameColor() {
        guard frameColors.count > 1 else {
            return
        }

        _ = frameColors.popLast()
    }
}

extension Bike: Encodable {
    // TODO: Complete this as features and fields are added
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(bikeDescription, forKey: .bikeDescription)
        try container.encode(frameModel, forKey: .frameModel)
        try container.encode(frameColors, forKey: .frameColors)
        try container.encode(manufacturerName, forKey: .manufacturerName)
        try container.encode(serial, forKey: .serial)
        try container.encode(status, forKey: .status)
        try container.encode(typeOfCycle.rawValue, forKey: .cycleTypeSlug)
        if let stolenCoordinates {
            try container.encode([stolenCoordinates.coordinate.latitude,
                                  stolenCoordinates.coordinate.longitude], forKey: .stolenLocation)
        } else {
            try container.encode(Array<Int>(), forKey: .stolenLocation)
        }
        try container.encode(stolenLocation, forKey: .stolenLocation)
        if let dateStolen {
            try container.encode(dateStolen.timeIntervalSince1970, forKey: .dateStolen)
        }
        try container.encode(url, forKey: .url)
        try container.encode(publicImages, forKey: .publicImages)
    }
}

enum BikeStatus: String, Codable {
    case withOwner
    case found
    case stolen
    case abandoned
    case impounded
    case unregisteredParkingNotification

    enum CodingKeys: String, CodingKey {
        case withOwner = "with_owner"
        case found
        case stolen
        case abandoned
        case impounded
        case unregisteredParkingNotification = "unregistered_parking_notification"
    }
}
