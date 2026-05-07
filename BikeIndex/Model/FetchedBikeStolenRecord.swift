//
//  FetchedBikeStolenRecord.swift
//  BikeIndex
//
//  Created by Milo Wyner on 2/13/26.
//

import CoreLocation

/// Data model to represent a stolen record when fetching a bike.
/// See https://bikeindex.org/documentation/api_v3#!/bikes/GET_version_bikes_id_format_get_0
struct FetchedBikeStolenRecord: Codable, ResponseModelInstantiable {
    typealias ModelInstance = StolenBikeRecord

    let date_stolen: TimeInterval?
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

    func modelInstance() -> StolenBikeRecord {
        StolenBikeRecord(
            dateStolen: date_stolen.map { Date(timeIntervalSince1970: $0) },
            location: location,
            latitude: latitude,
            longitude: longitude,
            theftDescription: theft_description,
            lockingDescription: locking_description,
            lockDefeatDescription: lock_defeat_description,
            policeReportNumber: police_report_number,
            policeReportDepartment: police_report_department,
            createdAt: created_at.map { Date(timeIntervalSince1970: $0) },
            createOpen311: create_open311,
            id: id
        )
    }
}
