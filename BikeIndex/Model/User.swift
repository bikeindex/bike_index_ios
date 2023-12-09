//
//  User.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData
import OSLog

@Model final class AuthenticatedUser: BikeIndexIdentifiable, CustomDebugStringConvertible {
    // TODO: Check if this can be Int
    @Attribute(.unique) private(set) var identifier: String
    @Relationship(deleteRule: .cascade) var user: User?

    @Transient let uuid = UUID().uuidString

    //    let bikeIds: [String]

    //    @Relationship(deleteRule: .cascade)
    //    private(set) var memberships: [Organization] = []

    init(identifier: String) {
        self.identifier = identifier
        Logger.model.debug("Authuser.init identifier: \(identifier)")
    }

    var debugDescription: String {
        "AuthenticatedUser: \(uuid)" // Rails.identifier=(identifier), SwiftData.id=(id), user=(String(describing: user))" // , memberships=\(memberships)"
    }
}

@Model final class User { // CustomDebugStringConvertible {
    @Attribute(.unique) fileprivate(set) var email: String
    fileprivate(set) var username: String
    fileprivate(set) var name: String
    fileprivate(set) var additionalEmails: [String]
    fileprivate(set) var createdAt: Date
    fileprivate(set) var image: URL?
    fileprivate(set) var twitter: URL?

    @Relationship(inverse: \AuthenticatedUser.user)
    fileprivate(set) var parent: AuthenticatedUser?

    init(username: String, name: String, email: String, additionalEmails: [String], createdAt: Date, image: URL? = nil, twitter: URL? = nil) {
        self.username = username
        self.name = name
        self.email = email.lowercased()
        self.additionalEmails = additionalEmails
        self.createdAt = createdAt
        self.image = image
        self.twitter = twitter
    }
}

@Model final class Organization {
    @Attribute(.unique) let identifier: Int
    let name: String
    let slug: String
    let accessToken: Token
    let userIsOrganizationAdmin: Bool

    //    @Relationship(deleteRule: .cascade, inverse: \AuthenticatedUser.memberships)
    //    var authorizedUsers: [AuthenticatedUser]? = []

    init(name: String, slug: String, identifier: Int, accessToken: Token, userIsOrganizationAdmin: Bool) {
        Logger.model.debug("Org.init w/ identifier \(identifier)")
        self.name = name
        self.slug = slug
        self.identifier = identifier
        self.accessToken = accessToken
        self.userIsOrganizationAdmin = userIsOrganizationAdmin
    }
}

