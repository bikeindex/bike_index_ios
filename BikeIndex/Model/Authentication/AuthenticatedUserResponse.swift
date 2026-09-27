//
//  MeResponse.swift
//  BikeIndex
//
//  Created by Jack on 12/6/23.
//

import Foundation
import OSLog
import SwiftData

struct AuthenticatedUserResponse: ResponseDecodable, ResponseModelInstantiable {
    typealias ModelInstance = AuthenticatedUser

    let id: String
    let user: UserResponse
    let bike_ids: [Int]
    /// Only present when the access token has the `read_organization_membership` scope.
    let memberships: [OrganizationResponse]?

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

        let organization_name: String
        let organization_short_name: String
        let organization_slug: String
        let organization_id: Int
        let organization_access_token: String
        let organization_logo_url: URL?
        let user_is_organization_admin: Bool
        /// The per-user, per-organization menu served by `UserServices::MenuItemsOrg`.
        let menu: [MenuItemJSON]

        func modelInstance() -> ModelInstance {
            Organization(
                identifier: organization_id,
                name: organization_name,
                shortName: organization_short_name,
                slug: organization_slug,
                logo: organization_logo_url,
                accessToken: organization_access_token,
                userIsOrganizationAdmin: user_is_organization_admin,
                menu: menu.map { item in
                    MenuItem(
                        type: item.type,
                        label: item.label,
                        key: item.key,
                        icon: item.icon,
                        path: item.path,
                        matchPaths: item.matchPaths?.paths ?? [],
                        matchParams: item.matchParams,
                        childrenJSON: (try? JSONEncoder().encode(item.children)) as Data?)
                })
        }
    }
}

