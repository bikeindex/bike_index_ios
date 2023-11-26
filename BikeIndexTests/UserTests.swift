//
//  UserTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/25/23.
//

import XCTest

final class UserTests: XCTestCase {

    func test_user() throws {
        let input = 
"""
{
    "username": "d16b16aea831b",
    "name": "Test User",
    "email": "test@example.com",
    "secondary_emails": [],
    "twitter": null,
    "created_at": 1694235377,
    "image": null
}
"""
        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let user = try JSONDecoder().decode(User.self, from: inputData)

        XCTAssertEqual(user.username, "d16b16aea831b")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1694235377))
        XCTAssertNil(user.image)
    }

    func test_authenticated_user() throws {
        let input =
"""
{
    "id": "591441",
    "user": {
        "username": "gdemxv0lwdgzx3qqpbp4rw",
        "name": "Jack Alto",
        "email": "altostratus900@gmail.com",
        "secondary_emails": [

        ],
        "twitter": null,
        "created_at": 1694235377,
        "image": null
    },
    "bike_ids": [

    ],
    "memberships": [
        {
            "organization_name": "Hogwarts School of Witchcraft and Wizardry",
            "organization_slug": "hogwarts",
            "organization_id": 818,
            "organization_access_token": "7133c88e912562ff65880c28d9350b75",
            "user_is_organization_admin": true
        }
    ]
}
"""

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let authenticatedUser = try JSONDecoder().decode(AuthenticatedUser.self, from: inputData)

        let user = authenticatedUser.user
        XCTAssertEqual(user.username, "d16b16aea831b")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1694235377))
        XCTAssertNil(user.image)

        XCTAssertEqual(authenticatedUser.identifier, "591441")

        let organization = try XCTUnwrap(authenticatedUser.memberships.first)
        XCTAssertEqual(authenticatedUser.memberships.count, 1)

        XCTAssertEqual(organization.name, "Hogwarts School of Witchcraft and Wizardry")
        XCTAssertEqual(organization.slug, "hogwarts")
        XCTAssertEqual(organization.identifier, 818)
        XCTAssertEqual(organization.accessToken, "7133c88e912562ff65880c28d9350b75")
        XCTAssertEqual(organization.userIsOrganizationAdmin, true)
    }
}
