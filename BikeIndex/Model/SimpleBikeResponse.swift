//
//  SimpleBikeResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/10/23.
//

import Foundation
import MapKit

/// Returned by POST /v3/bikes "Add a bike to the index" -- see ``Bikes/postBikes(form:)``
struct RegisterBikeResponseContainer: ResponseDecodable {
    var bike: SimpleBikeResponse
    var claim_url: URL?
}

/// Returned by GET /v3/me/bikes "Current user's bikes*" -- see ``Me/bikes``
struct MultipleBikeResponseContainer: ResponseDecodable {
    var bikes: [SimpleBikeResponse]
}

// MARK: -

struct SimpleBikeResponse: ResponseModelInstantiable {

    /// Rails ID
    let id: Int?
    let description: String?
    let frame_model: String?
    let frame_colors: [String]
    /// Also accepts manufacturer identifier Int
    let manufacturer_name: String
    let year: Int?
    let cycle_type_slug: BicycleType
    let propulsion_type_slug: PropulsionType

    /// Nil if the serial number is absent
    let serial: String?

    let status: BikeStatus
    let stolen_coordinates: [CLLocationDegrees]?
    let stolen_location: String?
    let date_stolen: TimeInterval?

    let large_img: URL?
    let thumb: URL?
    let url: URL
    let api_url: URL?
    let public_images: [String]?

    let registration_created_at: TimeInterval?
    let registration_updated_at: TimeInterval?

    // MARK: - ResponseModelInstantiable for BikeResponse

    func modelInstance() -> Bike {
        let stolenCoordinateLatitude: CLLocationDegrees
        let stolenCoordinateLongitude: CLLocationDegrees

        if let stolen_coordinates,
            stolen_coordinates.count == 2,
            let lat = stolen_coordinates.first,
            let lon = stolen_coordinates.last
        {
            stolenCoordinateLatitude = lat
            stolenCoordinateLongitude = lon
        } else {
            stolenCoordinateLatitude = CLLocationDegrees.nan
            stolenCoordinateLongitude = CLLocationDegrees.nan
        }
        let dateStolen = date_stolen.map { Date(timeIntervalSince1970: $0) }

        let firstColor = frame_colors.first.flatMap { FrameColor(rawValue: $0) } ?? .black

        var secondColor: FrameColor?
        var thirdColor: FrameColor?
        if frame_colors.count > 1 {
            secondColor = FrameColor(rawValue: frame_colors[1])
        }
        if frame_colors.count > 2 {
            thirdColor = FrameColor(rawValue: frame_colors[2])
        }

        assert(registration_created_at != nil)
        assert(registration_updated_at != nil)

        return Bike(
            identifier: id ?? Int.min,
            bikeDescription: description,
            frameModel: frame_model,
            primaryColor: firstColor,
            secondaryColor: secondColor,
            tertiaryColor: thirdColor,
            manufacturerName: manufacturer_name,
            year: year,
            typeOfCycle: cycle_type_slug,
            typeOfPropulsion: propulsion_type_slug,
            serial: serial,
            status: status,
            stolenCoordinateLatitude: stolenCoordinateLatitude,
            stolenCoordinateLongitude: stolenCoordinateLongitude,
            dateStolen: dateStolen,
            largeImage: large_img,
            thumb: thumb,
            url: url,
            apiUrl: api_url,
            publicImages: public_images ?? [],
            createdAt: registration_created_at.map { Date(timeIntervalSince1970: $0) },
            updatedAt: registration_updated_at.map { Date(timeIntervalSince1970: $0) }
        )
    }
}
