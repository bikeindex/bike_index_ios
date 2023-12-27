//
//  Bike.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData
import MapKit

@Model final class Bike {
    @Attribute(.unique) var identifier: Int
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
    var typeOfCycle: BicycleType

    /// Nil if the serial number is missing
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
    }

    init(identifier: Int, bikeDescription: String? = nil, frameModel: String? = nil, primaryColor: FrameColor, secondaryColor: FrameColor? = nil, tertiaryColor: FrameColor? = nil, manufacturerName: String, year: Int? = nil, typeOfCycle: BicycleType, serial: String? = nil, status: BikeStatus, stolenCoordinateLatitude: CLLocationDegrees, stolenCoordinateLongitude: CLLocationDegrees, stolenLocation: String? = nil, dateStolen: Date? = nil, thumb: URL? = nil, url: URL, apiUrl: URL? = nil, publicImages: [String]) {
        self.identifier = identifier
        self.bikeDescription = bikeDescription
        self.frameModel = frameModel
        self.frameColorPrimary = primaryColor
        self.frameColorSecondary = secondaryColor
        self.frameColorTertiary = tertiaryColor
        self.manufacturerName = manufacturerName
        self.year = year
        self.typeOfCycle = typeOfCycle
        self.serial = serial
        self.status = status
        self.stolenCoordinateLatitude = stolenCoordinateLatitude
        self.stolenCoordinateLongitude = stolenCoordinateLongitude
        self.stolenLocation = stolenLocation
        self.dateStolen = dateStolen
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
}

enum BikeStatus: String, Codable {
    case withOwner = "with owner"
    case found
    case stolen
    case abandoned
    case impounded
    case unregisteredParkingNotification = "unregistered parking notification"
}
