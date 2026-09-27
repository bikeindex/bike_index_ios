//
//  UserTests.swift
//  UnitTests
//
//  Created by Jack on 11/25/23.
//

import OSLog
import SwiftData
import XCTest

@testable import BikeIndex

final class UserTests: XCTestCase {

    func test_user() throws {
        let input = MockData.userJson
        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let response_user = try JSONDecoder().decode(
            AuthenticatedUserResponse.UserResponse.self, from: inputData)
        let user = response_user.modelInstance()

        XCTAssertEqual(user.username, "00d66fc4724cad")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1_694_235_377))
        XCTAssertNil(user.image)
    }

    @MainActor
    func test_authenticated_user() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: AuthenticatedUser.self, User.self, Organization.self, MenuItem.self,
            configurations: config)

        let input = MockData.authenticatedUserJson

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let response_authenticatedUser = try JSONDecoder()
            .decode(AuthenticatedUserResponse.self, from: inputData)
        let expectation = XCTestExpectation(description: "Model should be persisted")

        let authenticatedUser = response_authenticatedUser.modelInstance()

        Task { @MainActor in
            container.mainContext.insert(authenticatedUser)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        let user = response_authenticatedUser.user.modelInstance()
        XCTAssertEqual(user.username, "00d66fc4724cad")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1_694_235_377))
        XCTAssertNil(user.image)

        authenticatedUser.user = user
        XCTAssertEqual(authenticatedUser.identifier, "456654")

        // Memberships are served as an array when the token has the scope.
        let memberships = try XCTUnwrap(response_authenticatedUser.memberships)
        XCTAssertEqual(memberships.count, 1)
        let organization = memberships.first!.modelInstance()
        XCTAssertEqual(organization.identifier, 1234)
        XCTAssertEqual(organization.slug, "testers")
        XCTAssertTrue(organization.userIsOrganizationAdmin)
        XCTAssertFalse(organization.menu.isEmpty)
    }

    /// A `GET /me` payload without the `memberships` key (token lacks the
    /// `read_organization_membership` scope). Must decode with `memberships == nil`.
    @MainActor
    func test_authenticated_user_without_memberships_key() throws {
        let json =
            """
            {
                "id": "456654",
                "user": {
                    "username": "00d66fc4724cad",
                    "name": "Test User",
                    "email": "test@example.com",
                    "secondary_emails": [],
                    "twitter": null,
                    "created_at": 1694235377,
                    "image": null
                },
                "bike_ids": []
            }
            """
        let inputData = try XCTUnwrap(json.data(using: .utf8))
        let response = try JSONDecoder().decode(AuthenticatedUserResponse.self, from: inputData)

        XCTAssertNil(response.memberships)

        let user = response.user.modelInstance()
        XCTAssertTrue(user.organizations.isEmpty)

        // And the model instance still builds without crashing.
        let authUser = response.modelInstance()
        XCTAssertEqual(authUser.identifier, "456654")
    }

    /// A `GET /me` payload with an empty `memberships` array. Must decode cleanly.
    @MainActor
    func test_authenticated_user_with_empty_memberships_array() throws {
        let json =
            """
            {
                "id": "456654",
                "user": {
                    "username": "00d66fc4724cad",
                    "name": "Test User",
                    "email": "test@example.com",
                    "secondary_emails": [],
                    "twitter": null,
                    "created_at": 1694235377,
                    "image": null
                },
                "bike_ids": [],
                "memberships": []
            }
            """
        let inputData = try XCTUnwrap(json.data(using: .utf8))
        let response = try JSONDecoder().decode(AuthenticatedUserResponse.self, from: inputData)

        let memberships = try XCTUnwrap(response.memberships)
        XCTAssertTrue(memberships.isEmpty)

        let user = response.user.modelInstance()
        XCTAssertTrue(user.organizations.isEmpty)
    }

}
