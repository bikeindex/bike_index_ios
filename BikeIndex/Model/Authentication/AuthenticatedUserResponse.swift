//
//  MeResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/6/23.
//

import Foundation
import SwiftData
import OSLog

/// Convert a network response from a Decodable struct into its corresponding @Model class instance.
protocol ResponseModelInstantiable {
    associatedtype ModelInstance

    func modelInstance() -> ModelInstance
}

struct AuthenticatedUserResponse: Decodable, ResponseModelInstantiable {
    typealias ModelInstance = AuthenticatedUser

    let id: String
    let user: UserResponse
    let bike_ids: [String]
    let memberships: [OrganizationResponse]

    func modelInstance() -> ModelInstance {
        ModelInstance(identifier: id)
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
            User(username: username,
                      name: name,
                      email: email,
                      additionalEmails: secondary_emails,
                      createdAt: Date(timeIntervalSince1970: created_at),
                      image: image,
                      twitter: twitter)
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
            Organization(name: organization_name,
                         slug: organization_slug,
                         identifier: organization_id,
                         accessToken: organization_access_token, 
                         userIsOrganizationAdmin: user_is_organization_admin)
        }
    }
}
