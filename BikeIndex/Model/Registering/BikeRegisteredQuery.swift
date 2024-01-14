//
//  BikeRegisteredQuery.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

struct BikeRegisteredQuery: Encodable {
    // MARK: Required
    /// The serial number for the bike (use ‘made_without_serial’ if the bike doesn’t have a serial, ‘unknown’ if the serial is not known)
    let serial: String
    let ownerEmail: String
    /// Organization (ID or slug) to perform the check from. Only works if user is a member of the organization
    let organizationSlug: String

    // MARK: Not required
    /// Manufacturer name or ID
    let manufacturer: String?
    /// If using a phone number for registration, rather than email
    let ownerEmailIsPhoneNumber: Bool?

    enum CodingKeys: String, CodingKey {
        case serial
        case ownerEmail = "owner_email"
        case organizationSlug = "organization_slug"
        case manufacturer
        case ownerEmailIsPhoneNumber = "owner_email_is_phone_number"
    }
}

struct BikeRegisteredQueryResponse: Decodable {
    /// If a match was found
    let registered: Bool
    /// If a match was found and the user has claimed the bike
    let claimed: Bool
    /// If a match was found and it can be edited by the current token (e.g. was registered by the organization)
    let can_edit: Bool
}
