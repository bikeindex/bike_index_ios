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
/// Authoritative reference for a user known to be signed-in.
/// Lightweight and refers to ``Bike`` and ``User``relationships for full details.
@Model final class AuthenticatedUser {
    /// NOTE: AuthenticatedUser returns a string for an identifier.
    @Attribute(.unique) private(set) var identifier: String
    /// Refer to a ``User`` object for the full account details.
    @Relationship(deleteRule: .cascade) var user: User?

    /// Associate the bikes that are owned by a user (usually the one currently logged-in).
    @Relationship(inverse: \Bike.authenticatedOwner)
    var bikes: [Bike]

    /// Create an AuthenticatedUser
    /// - Parameters:
    ///   - identifier: The user ID from the server for this account.
    ///   - bikes: An array of bikes owned by this account, if known.
    ///   Otherwise relationships will be connected later.
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
