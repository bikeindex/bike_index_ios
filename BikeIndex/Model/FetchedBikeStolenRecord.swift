//
//  FetchedBikeStolenRecord.swift
//  BikeIndex
//
//  Created by Milo Wyner on 2/13/26.
//

import CoreLocation

/// Data model to represent a stolen record when fetching a bike.
/// See https://bikeindex.org/documentation/api_v3#!/bikes/GET_version_bikes_id_format_get_0
struct FetchedBikeStolenRecord: Codable {
    let date_stolen: Int?
    let location: String?
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
    let theft_description: String?
    let locking_description: String?
    let lock_defeat_description: String?
    let police_report_number: String?
    let police_report_department: String?
    let created_at: TimeInterval?
    let create_open311: Bool?
    let id: Int?
}
