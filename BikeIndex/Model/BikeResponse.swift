//
//  BikeResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/10/23.
//

import Foundation
import MapKit

struct BikeResponseContainer: ResponseModelInstantiable {
    typealias ModelInstance = Bike

    var bike: BikeResponse
    var claim_url: URL?

    func modelInstance() -> ModelInstance {
        bike.modelInstance()
    }
}


struct BikeResponse: ResponseModelInstantiable {

    /// Rails ID
    let id: Int?
    let description: String?
    let frame_model: String?
    let frame_colors: [String]
    /// Also accepts manufacturer identifier Int
    let manufacturer_name: String
    let year: Int?
    let cycle_type_slug: BicycleType

    /// Nil if the serial number is absent
    let serial: String?

    let status: BikeStatus
    let stolen_coordinates: [CLLocationDegrees]?
    let stolen_location: String?
    let date_stolen: TimeInterval?

    let thumb: URL?
    let url: URL
    let api_url: URL?
    let public_images: [String]

    // MARK: - ResponseModelInstantiable for BikeResponse

    typealias ModelInstance = Bike

    func modelInstance() -> Bike {
        let stolenCoordinateLatitude: CLLocationDegrees
        let stolenCoordinateLongitude: CLLocationDegrees

        if let stolen_coordinates,
           stolen_coordinates.count == 2,
           let lat = stolen_coordinates.first,
           let lon = stolen_coordinates.last {
            stolenCoordinateLatitude = lat
            stolenCoordinateLongitude = lon
        } else {
            stolenCoordinateLatitude = CLLocationDegrees.nan
            stolenCoordinateLongitude = CLLocationDegrees.nan
        }
        let dateStolen = date_stolen.map { Date(timeIntervalSince1970: $0) }

        let firstColor = frame_colors.first.flatMap { FrameColor(rawValue: $0) } ?? .black
        let secondColor = FrameColor(rawValue: frame_colors[1])
        let thirdColor = FrameColor(rawValue: frame_colors[2])

        return Bike(identifier: id ?? Int.min,
                    bikeDescription: description,
                    frameModel: frame_model,
                    primaryColor: firstColor,
                    secondaryColor: secondColor,
                    tertiaryColor: thirdColor,
                    manufacturerName: manufacturer_name,
                    typeOfCycle: cycle_type_slug,
                    serial: serial,
                    status: status,
                    stolenCoordinateLatitude: stolenCoordinateLatitude,
                    stolenCoordinateLongitude: stolenCoordinateLongitude,
                    dateStolen: dateStolen,
                    url: url,
                    apiUrl: api_url,
                    publicImages: public_images)
    }
}
