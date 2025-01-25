//
//  User.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import OSLog
import SwiftData

/// Only one authenticated user can exist at a time.
@Model final class AuthenticatedUser: BikeIndexIdentifiable {
    // TODO: Check if `identifier` can be Int
    @Attribute(.unique) private(set) var identifier: String
    /// AuthenticatedUser controls a general reference.
    @Relationship(deleteRule: .cascade) var user: User?

    /// Associate the bikes that are owned by a user (usually the one currently logged-in).
    @Relationship(inverse: \Bike.authenticatedOwner)
    var bikes: [Bike]

    init(identifier: String, bikes: [Bike]) {
        self.identifier = identifier
        self.bikes = []
    }
}

@Model final class User {
    @Attribute(.unique) fileprivate(set) var email: String
    fileprivate(set) var username: String
    fileprivate(set) var name: String
    fileprivate(set) var additionalEmails: [String]
    fileprivate(set) var createdAt: Date
    fileprivate(set) var image: URL?
    fileprivate(set) var twitter: URL?

    @Relationship(inverse: \AuthenticatedUser.user)
    fileprivate(set) var parent: AuthenticatedUser?

    @Relationship(inverse: \Bike.owner)
    fileprivate(set) var bikes: [Bike]

    init(
        email: String, username: String, name: String, additionalEmails: [String], createdAt: Date,
        image: URL? = nil, twitter: URL? = nil, parent: AuthenticatedUser? = nil, bikes: [Bike]
    ) {
        self.email = email
        self.username = username
        self.name = name
        self.additionalEmails = additionalEmails
        self.createdAt = createdAt
        self.image = image
        self.twitter = twitter
        self.parent = parent
        self.bikes = bikes
    }
}

@Model final class Organization {
    @Attribute(.unique) var identifier: Int
    var name: String
    var slug: String
  var accessToken: Token
    var userIsOrganizationAdmin: Bool

    // TODO: Fill-in Organization relationships and functionality
    //    @Relationship(deleteRule: .cascade, inverse: \AuthenticatedUser.memberships)
    //    var authorizedUsers: [AuthenticatedUser]? = []

    init(
        name: String, slug: String, identifier: Int, accessToken: Token,
        userIsOrganizationAdmin: Bool
    ) {
        Logger.model.debug("Org.init w/ identifier \(identifier)")
        self.name = name
        self.slug = slug
        self.identifier = identifier
        self.accessToken = accessToken
        self.userIsOrganizationAdmin = userIsOrganizationAdmin
    }
}
