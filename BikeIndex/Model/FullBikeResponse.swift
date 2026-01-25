//
//  GetBikeIdResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/15/25.
//

import Foundation
import MapKit
import SwiftData

/// Returned by GET /v3/bikes/{id} "View bike with a given ID" -- see ``Bikes/bikes(identifier:)``
struct FullBikeResponseContainer: ResponseDecodable {
    var bike: FullBikeResponse
}

// MARK: -

struct PublicImageResponse: ResponseModelInstantiable {
    var name: String
    var full: URL?
    var large: URL?
    var medium: URL?
    var thumb: URL?
    var id: Int

    func modelInstance() -> FullPublicImage {
        FullPublicImage(
            name: name,
            full: full,
            large: large,
            medium: medium,
            thumb: thumb,
            id: id)
    }
}

extension [PublicImageResponse]? {
    func modelInstances() -> [FullPublicImage] {
        self?.map { $0.modelInstance() } ?? []
    }

    var simplePublicImages: [String] {
        self?.compactMap { $0.full?.absoluteString } ?? []
    }
}

struct FullBikeResponse: ResponseModelInstantiable {

    /// Rails ID
    let id: Int?
    let title: String?
    let description: String?

    let registry_name: String?
    let registry_url: URL?

    let frame_model: String?
    let frame_colors: [String]
    let paint_description: String?

    /// Also accepts manufacturer identifier Int
    let manufacturer_name: String
    let manufacturer_id: Int?

    let year: Int?
    let cycle_type_slug: BicycleType
    let propulsion_type_slug: PropulsionType

    /// Nil if the serial number is absent
    let serial: String?

    let status: BikeStatus
    let stolen: Bool
    let stolen_coordinates: [CLLocationDegrees]?
    let stolen_location: String?
    let date_stolen: TimeInterval?
    let location_found: Bool?

    let large_img: URL?
    let thumb: URL?
    let url: URL
    let api_url: URL?
    let public_images: [PublicImageResponse]?
    let is_stock_img: Bool

    let registration_created_at: TimeInterval?
    let registration_updated_at: TimeInterval?

    let extra_registration_number: Int?
    let rear_tire_narrow: Bool?
    let test_bike: Bool?
    let rear_wheel_size_iso_bsd: Bool?
    let front_wheel_size_iso_bsd: Bool?
    let handlebar_type_slug: String?
    let frame_material_slug: String?
    let front_gear_type_slug: String?
    let rear_gear_type_slug: String?
    let additional_registration: String?
    let components: [String]

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

        return Bike(
            identifier: id ?? Int.min,
            title: title,
            bikeDescription: description,
            registryName: registry_name,
            registryURL: registry_url,
            frameModel: frame_model,
            primaryColor: firstColor,
            secondaryColor: secondColor,
            tertiaryColor: thirdColor,
            paintDescription: paint_description,
            manufacturerName: manufacturer_name,
            manufacturerID: manufacturer_id,
            year: year,
            typeOfCycle: cycle_type_slug,
            typeOfPropulsion: propulsion_type_slug,
            serial: serial,
            status: status,
            stolen: stolen,
            stolenCoordinateLatitude: stolenCoordinateLatitude,
            stolenCoordinateLongitude: stolenCoordinateLongitude,
            dateStolen: dateStolen,
            locationFound: location_found,
            largeImage: large_img,
            thumb: thumb,
            url: url,
            apiUrl: api_url,
            publicImages: public_images.simplePublicImages,
            fullPublicImages: public_images.modelInstances(),
            isStockImage: is_stock_img,
            createdAt: registration_created_at.map { Date(timeIntervalSince1970: $0) },
            updatedAt: registration_updated_at.map { Date(timeIntervalSince1970: $0) },
            extraRegistrationNumber: extra_registration_number,
            rearTireNarrow: rear_tire_narrow,
            testBike: test_bike,
            rearWheelSizeISOBSD: rear_wheel_size_iso_bsd,
            frontWheelSizeISOBSD: front_wheel_size_iso_bsd,
            handlebarTypeSlug: handlebar_type_slug,
            frameMaterialSlug: frame_material_slug,
            frontGearTypeSlug: front_gear_type_slug,
            rearGearTypeSlug: rear_gear_type_slug,
            additionalRegistration: additional_registration,
            components: components
        )
    }
}
