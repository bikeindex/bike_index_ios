//
//  StolenRecord.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

struct StolenRecord: Encodable {
    var phone: String
    var city: String
    var country: Countries.ISO? = Locale.current.region?.identifier
    var zipcode: String?
    var state: US_States.Abbreviation?

    /// Also used for text-description of intersection
    var address: String?
    var date_stolen: Int?
    var police_report_number: String?
    var police_report_department: String?
    var show_address: Bool?
    var theft_description: String?
}
