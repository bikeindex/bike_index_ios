//
//  UserRelationshipTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/29/23.
//

import XCTest
import SwiftData
import OSLog
@testable import BikeIndex

@MainActor
final class UserRelationshipTests: XCTestCase {

    let timeout = 30.0

    func test_authenticated_user_new_session_and_parsing() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: User.self, Organization.self, AuthenticatedUser.self,
                                           configurations: config)
        let input = MockData.authenticatedUserJson

        let userResults0 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults0.count, 0)

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let response_authenticateduser = try JSONDecoder()
            .decode(AuthenticatedUserResponse.self, from: inputData)
        let expectation = XCTestExpectation(description: "SwiftData operations will complete.")

        let authenticatedUser = response_authenticateduser.modelInstance()

        let authResults1 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults1.count, 0)

        let userResults1 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults1.count, 0)

        Task { @MainActor in
            let context = container.mainContext
            context.insert(authenticatedUser)
            try context.save()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)

        let user = response_authenticateduser.user.modelInstance()
        authenticatedUser.user = user
        Logger.tests.debug("User is \(user.username, privacy: .public)")
        let username: String = user.username
        XCTAssert(username == "00d66fc4724cad")

        let name: String = user.name
//        Logger.tests.debug("Found user.name \(name), assertion \(name == "Test User")")
        XCTAssert(name == "Test User")

//        let additionalEmails: [String] = user.additionalEmails
//        XCTAssertTrue(additionalEmails.isEmpty)

        XCTAssertNil(user.twitter)

//        let createdAt: Date = user.createdAt
//        XCTAssert(createdAt == Date(timeIntervalSince1970: 1694235377))

        XCTAssertNil(user.image)

        let authIdentifier = authenticatedUser.identifier
        Logger.tests.debug("Found authIdentifier \(authIdentifier), assertion \(authIdentifier == "591441")")
        XCTAssert(authIdentifier == "456654")

        /*
        let memberships = authenticatedUser.memberships
        let organization = try XCTUnwrap(authenticatedUser.memberships.first)
        XCTAssertFalse(memberships.isEmpty)

        let orgName: String = organization.name
        XCTAssert(orgName == "Hogwarts School of Witchcraft and Wizardry")

        XCTAssertEqual(organization.slug, "hogwarts")

        XCTAssertEqual(organization.identifier, 818)

        XCTAssertEqual(organization.accessToken, "bdcc3c3c85716167ce566ab1418ab13b")

        XCTAssertTrue(organization.userIsOrganizationAdmin)

         let memberResults = try container.mainContext.fetch(FetchDescriptor<Organization>())
         XCTAssertEqual(memberResults.count, 1)

         */

        let authResults2 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults2.count, 1)

        let userResults2 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults2.count, 1)

    }

    func test_authenticated_user_new_session_overwrite() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)

        let container = try ModelContainer(for: User.self, Organization.self, AuthenticatedUser.self,
                                           configurations: config)
        Logger.model.trace("Container.id is \(config.id)")
        let input = MockData.authenticatedUserJson

        XCTAssertTrue(container.mainContext.autosaveEnabled)

        NotificationCenter.default.addObserver(forName: ModelContext.willSave, object: container.mainContext, queue: nil) { notif in
            Logger.views.error("Received will-save notification: \(notif.userInfo?.debugDescription ?? "<empty>", privacy: .public)")
            Logger.views.error("Received will-save notification: \(notif.debugDescription, privacy: .public)")
        }

        let userResults_preCreate = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults_preCreate.count, 0)

        let authResults_preCreate = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults_preCreate.count, 0)

        let existingUser = User(email: "test@example.com", username: "00d66fc4724cad", name: "Test User presave", additionalEmails: [], createdAt: Date(), parent: nil, bikes: [])

        let userResults_prefill_postcreate = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults_prefill_postcreate.count, 0)

        let authResults_prefill_postCreate = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults_prefill_postCreate.count, 0)

        let expect_user_prefill = XCTestExpectation(description: "Must prefill User before decoding")
        let expect_authUser_prefill = XCTestExpectation(description: "Must prefill AuthenticatedUser before decoding")
        container.mainContext.insert(existingUser)


        let existingAuth = AuthenticatedUser(identifier: "456654", bikes: [])

        existingAuth.user = existingUser

        container.mainContext.insert(existingAuth)

        let authResults_post_prefill = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults_post_prefill.count, 1)

        let userResults_post_prefill = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults_post_prefill.count, 1)

        XCTAssertNotNil(existingAuth.user)
        XCTAssertNotNil(existingAuth.id)
        XCTAssertNotNil(existingUser.id)

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let meResponse = try JSONDecoder()
            .decode(AuthenticatedUserResponse.self, from: inputData)

        let responseUser = meResponse.user.modelInstance()
        _ = meResponse.memberships.map { $0.modelInstance() }
        let responseAuthUser = meResponse.modelInstance()

        XCTAssertNil(responseAuthUser.id.storeIdentifier)
        XCTAssertNil(responseAuthUser.user)
        let expectation = XCTestExpectation(description: "SwiftData operations will complete.")

        Logger.tests.debug("attaching responseUser to responseAuth - \(String(reflecting: responseUser), privacy: .public)")
        responseAuthUser.user = responseUser

        let authResults1 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults1.count, 1)

        let userResults1 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults1.count, 1)

        container.mainContext.insert(responseAuthUser)
        do {
            try container.mainContext.save()
        } catch {
            Logger.tests.critical("Failed to save \(error)")
            Logger.tests.critical("Failed to save \(type(of: error))")
            Logger.tests.critical("Failed to save \(error.localizedDescription)")
            XCTFail(error.localizedDescription)
        }

        Logger.model.trace("@@º Attempting to inflate authenticatedUser.user)")

//        let usersUser = try XCTUnwrap(responseAuthUser.user)
//        Logger.tests.debug("User is \(usersUser.username, privacy: .public)")

        XCTAssertEqual(responseAuthUser.user?.username, "00d66fc4724cad")

        XCTAssertEqual(responseAuthUser.user?.name, "Test User")
        XCTAssertEqual(responseAuthUser.user?.name, "Test User")
        XCTAssertTrue(responseAuthUser.user?.additionalEmails.isEmpty ?? false)

        XCTAssertNil(responseAuthUser.user?.twitter)

        XCTAssertEqual(responseAuthUser.user?.createdAt, Date(timeIntervalSince1970: 1694235377))

        XCTAssertNil(responseAuthUser.user?.image)


        let authResults2 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults2.count, 1)

        let userResults2 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults2.count, 1)

    }

}
