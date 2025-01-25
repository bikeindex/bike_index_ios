//
//  MeResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/6/23.
//

import Foundation
import OSLog
import SwiftData

/// Convert a network response from a Decodable struct into its corresponding @Model class instance.
protocol ResponseModelInstantiable: Decodable {
    associatedtype ModelInstance

    func modelInstance() -> ModelInstance
}

struct AuthenticatedUserResponse: Decodable, ResponseModelInstantiable {
    typealias ModelInstance = AuthenticatedUser

    let id: String
    let user: UserResponse
    let bike_ids: [Int]
    let memberships: [OrganizationResponse]

    func modelInstance() -> ModelInstance {
        // AuthenticatedUser will be instantiated without bike model connections.
        // To be added after queries can be made.
        ModelInstance(
            identifier: id,
            bikes: [])
    }

    struct UserResponse: Decodable, ResponseModelInstantiable {
        typealias ModelInstance = User

        let email: String
        let username: String
        let name: String
        let secondary_emails: [String]
        let created_at: TimeInterval
        let image: URL?
        let twitter: URL?

        func modelInstance() -> User {
            User(
                email: email,
                username: username,
                name: name,
                additionalEmails: secondary_emails,
                createdAt: Date(timeIntervalSince1970: created_at),
                image: image,
                twitter: twitter,
                bikes: [])
        }
    }

    struct OrganizationResponse: Decodable, ResponseModelInstantiable {
        typealias ModelInstance = Organization

        let organization_id: Int
        let organization_slug: String
        let organization_name: String
        let organization_access_token: String
        let user_is_organization_admin: Bool

        func modelInstance() -> Organization {
            Organization(
                name: organization_name,
                slug: organization_slug,
                identifier: organization_id,
                accessToken: organization_access_token,
                userIsOrganizationAdmin: user_is_organization_admin)
        }
    }
}
