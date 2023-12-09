//
//  UserTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/25/23.
//

import XCTest
import SwiftData
import OSLog
@testable import BikeIndex

final class UserTests: XCTestCase {

    func test_user() throws {
        let input = MockData.userJson
        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let response_user = try JSONDecoder().decode(AuthenticatedUserResponse.UserResponse.self, from: inputData)
        let user = response_user.modelInstance()

        XCTAssertEqual(user.username, "d16b16aea831b")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1694235377))
        XCTAssertNil(user.image)
    }

    @MainActor 
    func test_authenticated_user() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self,
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
        XCTAssertEqual(user.username, "d16b16aea831b")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.additionalEmails, [])
        XCTAssertNil(user.twitter)
        XCTAssertEqual(user.createdAt, Date(timeIntervalSince1970: 1694235377))
        XCTAssertNil(user.image)

        authenticatedUser.user = user
        XCTAssertEqual(authenticatedUser.identifier, "591441")

//        let organization = try XCTUnwrap(authenticatedUser.memberships.first)
//        XCTAssertEqual(authenticatedUser.memberships.count, 1)

//        XCTAssertEqual(organization.name, "Hogwarts School of Witchcraft and Wizardry")
//        XCTAssertEqual(organization.slug, "hogwarts")
//        XCTAssertEqual(organization.identifier, 818)
//        XCTAssertEqual(organization.accessToken, "bdcc3c3c85716167ce566ab1418ab13b")
//        XCTAssertEqual(organization.userIsOrganizationAdmin, true)

    }

}
