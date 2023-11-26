//
//  UserTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/25/23.
//

import XCTest
import SwiftData
import OSLog

final class UserTests: XCTestCase {

    func test_user() throws {
        let input = MockData.userJson
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
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self,
                                           configurations: config)

        let input = MockData.authenticatedUserJson

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let authenticatedUser = try JSONDecoder().decode(AuthenticatedUser.self, from: inputData)
        let expectation = XCTestExpectation(description: "Open a file asynchronously.")

        Logger.tests.log("Enter task")
        Task { @MainActor in
            Logger.tests.log("Enter will insert")
            container.mainContext.insert(authenticatedUser)
            Logger.tests.log("Enter did insert")
            expectation.fulfill()
        }
        Logger.tests.log("After task")

        wait(for: [expectation], timeout: 10.0)

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
        XCTAssertEqual(organization.accessToken, "bdcc3c3c85716167ce566ab1418ab13b")
        XCTAssertEqual(organization.userIsOrganizationAdmin, true)

    }

    func test_authenticated_user_new_session_overwrite() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self,
                                           configurations: config)
        let input = MockData.authenticatedUserJson

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let authenticatedUser = try JSONDecoder().decode(AuthenticatedUser.self, from: inputData)
        let expectation = XCTestExpectation(description: "Open a file asynchronously.")

        Logger.tests.log("Enter task")
        Task { @MainActor in
            Logger.tests.log("Enter will insert")
            let context = container.mainContext

            try context.transaction {
                let authenticatedIdentifier = String(authenticatedUser.identifier)
                do {
                    let existingUsers = try context.fetch(FetchDescriptor<AuthenticatedUser>())
                }

                try context.delete(model: AuthenticatedUser.self, where: #Predicate {
                    user in
                    user.identifier != authenticatedIdentifier
                })

                context.insert(authenticatedUser)
            }

            Logger.tests.log("Enter did insert")
            expectation.fulfill()
        }
        Logger.tests.log("After task")

        wait(for: [expectation], timeout: 10.0)

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
