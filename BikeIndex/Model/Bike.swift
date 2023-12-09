//
//  Bike.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData
import MapKit

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
    /// Also accepts manufacturer identifier Int
    var manufacturerName: String
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

    struct Constants {
        /// The range of supported years for Bike models
        static let yearRange = 1900..<2100
        /// The range of **displayable** years for Bike models aka "inclusive 1900-2024"
        static let displayableYearRange = 1900..<2025
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
