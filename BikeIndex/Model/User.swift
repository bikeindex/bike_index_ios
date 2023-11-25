//
//  User.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData

@Model final class Organization: Decodable {
    @Attribute(.unique) let identifier: Int
    let name: String
    let slug: String
    let accessToken: Token
    let userIsOrganizationAdmin: Bool
    @Relationship(inverse: \AuthenticatedUser.memberships) var adminUsers: [AuthenticatedUser] = []

    init(name: String, slug: String, identifier: Int, accessToken: Token, userIsOrganizationAdmin: Bool) {
        self.name = name
        self.slug = slug
        self.identifier = identifier
        self.accessToken = accessToken
        self.userIsOrganizationAdmin = userIsOrganizationAdmin
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        identifier = try container.decode(Int.self, forKey: .identifier)
        accessToken = try container.decode(Token.self, forKey: .accessToken)
        userIsOrganizationAdmin = try container.decode(Bool.self, forKey: .userIsOrganizationAdmin)
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "organization_name"
        case slug = "organization_slug"
        case identifier = "organization_id"
        case accessToken = "organization_access_token"
        case userIsOrganizationAdmin = "user_is_organization_admin"
    }
}

@Model final class AuthenticatedUser: Decodable {
    // TODO: Check if this can be Int
    @Attribute(.unique) let identifier: String
    @Relationship(.unique, deleteRule: .cascade) let user: User
//    let bikeIds: [String]
    @Relationship(deleteRule: .nullify) let memberships: [Organization]

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case user
        case bikeIds = "bike_ids"
        case memberships
    }

    init(identifier: String, user: User, memberships: [Organization]) {
        self.identifier = identifier
        self.user = user
        self.memberships = memberships
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        user = try container.decode(User.self, forKey: .user)
        memberships = try container.decode([Organization].self, forKey: .memberships)
    }
}

@Model final class User: Decodable {
    @Attribute(.unique) let email: String
    let username: String
    let name: String
    let additionalEmails: [String]
    let createdAt: Date
    let image: URL?
    let twitter: URL?

    init(username: String, name: String, email: String, additionalEmails: [String], createdAt: Date, image: URL?, twitter: URL?) {
        self.username = username
        self.name = name
        self.email = email
        self.additionalEmails = additionalEmails
        self.createdAt = createdAt
        self.image = image
        self.twitter = twitter
    }

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
