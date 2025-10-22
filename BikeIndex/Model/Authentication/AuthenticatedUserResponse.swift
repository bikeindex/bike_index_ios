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
}
