//
//  RegisterBikeStolenRecord.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

/// Data model to represent a stolen bike when creating a new registration.
/// Required fields are phone and city.
/// See https://bikeindex.org/documentation/api_v3#!/bikes/POST_version_bikes_format_post_3
struct RegisterBikeStolenRecord: Codable {
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

    // MARK: Validation

    var isPhoneValid: Bool {
        !phone.isEmpty
    }

    var isCityValid: Bool {
        !city.isEmpty
    }
}
