//
//  Bike.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import MapKit
import SwiftData

@Model final class Bike {
    /// Rails-specific Bike identifier.
    typealias BikeIdentifier = Int

    @Attribute(.unique) var identifier: BikeIdentifier
    @Relationship var owner: User?
    @Relationship var authenticatedOwner: AuthenticatedUser?

    var bikeDescription: String?
    var frameModel: String?

    var frameColorPrimary: FrameColor
    var frameColorSecondary: FrameColor?
    var frameColorTertiary: FrameColor?

    @Transient var frameColors: [FrameColor] {
        [frameColorPrimary, frameColorSecondary, frameColorTertiary].compactMap { $0 }
    }

    /// Also accepts manufacturer identifier Int
    var manufacturerName: String
    var year: Int?

    /// Keyed by `cycle_type_slug`
    var typeOfCycle: BicycleType

    /// Keyed by `propulsion_type_slug`
    var typeOfPropulsion: PropulsionType

    /// Nil if the serial number is missing.
    /// There are various concepts of absent serial numbers
    /// such as "unknown" and also "made\_without\_serial" for certain older bikes.
    var serial: String?

    var status: BikeStatus
    /// SwiftData predicates are incompatible with Enums (like ``BikeStatus``) so we duplicate it :/ to make it queryable
    /// Add a default value of empty string, to be over-written by 1) ``Bike/init`` and 2) ``Bike/status/willSet``.
    var statusString: String = ""

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

    /// Full resolution main image
    var largeImage: URL?
    /// Small-scale main image
    var thumb: URL?
    var url: URL
    var apiUrl: URL?
    var publicImages: [String]

    struct Constants {
        /// The range of supported years for Bike models
        static let yearRange = 1900..<2100

        /// The range of **displayable** years for Bike models aka "inclusive 1900-2026"
        static let displayableYearRange = 1900..<2027
    }

    init(
        identifier: BikeIdentifier,
        bikeDescription: String? = nil,
        frameModel: String? = nil,
        primaryColor: FrameColor,
        secondaryColor: FrameColor? = nil,
        tertiaryColor: FrameColor? = nil,
        manufacturerName: String,
        year: Int? = nil,
        typeOfCycle: BicycleType,
        typeOfPropulsion: PropulsionType,
        serial: String? = nil,
        status: BikeStatus,
        stolenCoordinateLatitude: CLLocationDegrees,
        stolenCoordinateLongitude: CLLocationDegrees,
        stolenLocation: String? = nil,
        dateStolen: Date? = nil,
        largeImage: URL? = nil,
        thumb: URL? = nil,
        url: URL,
        apiUrl: URL? = nil,
        publicImages: [String]
    ) {
        self.identifier = identifier
        self.bikeDescription = bikeDescription
        self.frameModel = frameModel
        self.frameColorPrimary = primaryColor
        self.frameColorSecondary = secondaryColor
        self.frameColorTertiary = tertiaryColor
        self.manufacturerName = manufacturerName
        self.year = year
        self.typeOfCycle = typeOfCycle
        self.typeOfPropulsion = typeOfPropulsion
        self.serial = serial
        self.status = status
        self.statusString = status.rawValue
        self.stolenCoordinateLatitude = stolenCoordinateLatitude
        self.stolenCoordinateLongitude = stolenCoordinateLongitude
        self.stolenLocation = stolenLocation
        self.dateStolen = dateStolen
        self.largeImage = largeImage
        self.thumb = thumb
        self.url = url
        self.apiUrl = apiUrl
        self.publicImages = publicImages
    }

    init() {
        identifier = 0
        bikeDescription = ""
        frameModel = ""
        frameColorPrimary = .black

        manufacturerName = ""
        serial = nil
        status = .withOwner
        statusString = BikeStatus.withOwner.rawValue
        typeOfCycle = .bike
        typeOfPropulsion = .footPedal

        stolenCoordinateLatitude = 0
        stolenCoordinateLongitude = 0
        stolenLocation = ""
        dateStolen = Date.distantFuture
        let defaultUrl = URL(string: "about:blank").unsafelyUnwrapped
        largeImage = nil
        url = defaultUrl
        apiUrl = defaultUrl
        publicImages = []
    }

    // https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-derived-attributes-with-swiftdata
    func update<T>(keyPath: ReferenceWritableKeyPath<Bike, T>, to value: T) {
        print("Bike #\(identifier) updating \(keyPath) to \(value)")
        self[keyPath: keyPath] = value
        if keyPath == \.status {
            statusString = status.rawValue
        }
    }

}

extension Bike {
    // MARK: - Accessors for UI display

    @Transient var title: String {
        if let year {
            String(year) + " " + manufacturerName
        } else if let serial {
            manufacturerName + " " + serial
        } else {
            manufacturerName
        }
    }
}
