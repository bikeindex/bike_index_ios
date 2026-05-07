//
//  StolenBikeRecord.swift
//  BikeIndex
//
//  Created by Jack on 5/6/26.
//

import CoreLocation
import Foundation
import SwiftData

@Model final class StolenBikeRecord {
    @Relationship(inverse: \Bike.stolenRecord)
    var bike: Bike?

    var dateStolen: Date?
    var location: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var theftDescription: String?
    var lockingDescription: String?
    var lockDefeatDescription: String?
    var policeReportNumber: String?
    var policeReportDepartment: String?
    var createdAt: Date?
    var createOpen311: Bool?
    var id: Int?

    init(
        dateStolen: Date?,
        location: String?,
        latitude: CLLocationDegrees?,
        longitude: CLLocationDegrees?,
        theftDescription: String?,
        lockingDescription: String?,
        lockDefeatDescription: String?,
        policeReportNumber: String?,
        policeReportDepartment: String?,
        createdAt: Date?,
        createOpen311: Bool?,
        id: Int?
    ) {
        self.dateStolen = dateStolen
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.theftDescription = theftDescription
        self.lockingDescription = lockingDescription
        self.lockDefeatDescription = lockDefeatDescription
        self.policeReportNumber = policeReportNumber
        self.policeReportDepartment = policeReportDepartment
        self.createdAt = createdAt
        self.createOpen311 = createOpen311
        self.id = id
    }

    init() {
        dateStolen = nil
        location = ""
        latitude = 0
        longitude = 0
        theftDescription = ""
        lockingDescription = ""
        lockDefeatDescription = ""
        policeReportNumber = ""
        policeReportDepartment = ""
        createdAt = nil
        createOpen311 = false
        id = nil
    }
}
