//
//  User.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData

@Model final class AuthenticatedUser: Decodable {
    // TODO: Check if this can be Int
    @Attribute(.unique) let identifier: String
    @Relationship(.unique, deleteRule: .cascade) let user: User
//    let bikeIds: [String]
    let memberships: [String]

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case user
        case bikeIds = "bike_ids"
        case memberships
    }

    init(identifier: String, user: User, memberships: [String]) {
        self.identifier = identifier
        self.user = user
        self.memberships = memberships
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        user = try container.decode(User.self, forKey: .user)
        memberships = try container.decode([String].self, forKey: .memberships)
    }
}

@Model final class User: Decodable {
    let username: String
    let name: String
    let email: String
    let additionalEmails: [String]
    let createdAt: Date
    let image: URL?
    let twitter: URL?

    init() {
        username = ""
        name = ""
        email = ""
        additionalEmails = []
        createdAt = Date.distantPast
        image = nil
        twitter = nil
    }

    enum CodingKeys: String, CodingKey {
        case username
        case name
        case email
        case additionalEmails = "secondary_emails"
        case createdAt = "created_at"
        case image
        case twitter
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        additionalEmails = try container.decode([String].self, forKey: .additionalEmails)
        let createdAtTimestamp = try container.decode(TimeInterval.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        image = try container.decodeIfPresent(URL.self, forKey: .image)
        if let twitterString = try container.decodeIfPresent(String.self, forKey: .twitter) {
            twitter = URL(string: twitterString)
        }
    }

}
