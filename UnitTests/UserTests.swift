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
            for: AuthenticatedUser.self,
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
    }

}
