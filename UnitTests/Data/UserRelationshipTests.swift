//
//  UserRelationshipTests.swift
//  UnitTests
//
//  Created by Jack on 11/29/23.
//

import OSLog
import SwiftData
import XCTest

@testable import BikeIndex

@MainActor
final class UserRelationshipTests: XCTestCase {

    let timeout = 30.0

    func test_authenticated_user_new_session_and_parsing() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: User.self, Organization.self, MenuItem.self, AuthenticatedUser.self,
            configurations: config)
        let input = MockData.authenticatedUserJson

        let userResults0 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults0.count, 0)

        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let response_authenticateduser = try JSONDecoder()
            .decode(AuthenticatedUserResponse.self, from: inputData)
        let expectation = XCTestExpectation(description: "SwiftData operations will complete.")
        expectation.assertForOverFulfill = false

        let authenticatedUser = response_authenticateduser.modelInstance()

        let authResults1 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults1.count, 0)

        let userResults1 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults1.count, 0)

        var saveError: Error?
        Task { @MainActor in
            do {
                let context = container.mainContext
                context.insert(authenticatedUser)
                try context.save()
            } catch {
                saveError = error
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
        XCTAssertNil(saveError, "Failed to save authenticated user: \(String(describing: saveError))")

        let user = response_authenticateduser.user.modelInstance()
        authenticatedUser.user = user
        Logger.tests.debug("User is \(user.username, privacy: .public)")
        let username: String = user.username
        XCTAssert(username == "00d66fc4724cad")

        // The server serves organizations under a `memberships` array.
        let memberships = try XCTUnwrap(response_authenticateduser.memberships)
        let organizations = memberships.map { $0.modelInstance() }
        user.organizations = organizations
        XCTAssertFalse(organizations.isEmpty)

        let organization = try XCTUnwrap(organizations.first)
        XCTAssertEqual(organization.name, "Test account")
        XCTAssertEqual(organization.shortName, "Test account")
        XCTAssertEqual(organization.slug, "testers")
        XCTAssertEqual(organization.identifier, 1234)
        XCTAssertEqual(organization.accessToken, "59658bae53dec4cced6eafee0abc9670")
        XCTAssertTrue(organization.userIsOrganizationAdmin)
        XCTAssertNil(organization.logo)

        // The menu is served as nested groups, links and dividers.
        XCTAssertEqual(organization.menu.count, 3)
        let group = try XCTUnwrap(organization.menu.first)
        XCTAssertEqual(group.type, "group")
        XCTAssertEqual(group.key, "registrations")
        XCTAssertEqual(group.children.count, 3)
        XCTAssertEqual(group.children.last?.type, "disabled")
        XCTAssertEqual(organization.menu[1].type, "divider")
        let addBikeLink = try XCTUnwrap(organization.menu.last)
        XCTAssertEqual(addBikeLink.type, "link")
        XCTAssertEqual(addBikeLink.path, "/o/testers/registrations/new")
        // A `null` param value is a "match only when the param is absent" marker.
        XCTAssertEqual(addBikeLink.matchParams["parking_notification"] ?? nil, nil)
        XCTAssertTrue(addBikeLink.matchParams.keys.contains("parking_notification"))

        // The menu is stored on the model and round-trips through the context.
        let orgResults = try container.mainContext.fetch(FetchDescriptor<Organization>())
        XCTAssertEqual(orgResults.count, 1)
        let fetchedOrg = try XCTUnwrap(orgResults.first)
        XCTAssertEqual(fetchedOrg.menu.count, 3)
        XCTAssertEqual(fetchedOrg.menu.first?.children.count, 3)

        let menuResults = try container.mainContext.fetch(FetchDescriptor<MenuItem>())
        XCTAssertEqual(menuResults.count, 3)

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
        Logger.tests.debug(
            "Found authIdentifier \(authIdentifier), assertion \(authIdentifier == "591441")")
        XCTAssert(authIdentifier == "456654")

        let authResults2 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults2.count, 1)

        let userResults2 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults2.count, 1)

    }

    func test_authenticated_user_new_session_overwrite() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)

        let container = try ModelContainer(
            for: User.self, Organization.self, MenuItem.self, AuthenticatedUser.self,
            configurations: config)
        Logger.model.trace("Container.id is \(config.id)")
        let input = MockData.authenticatedUserJson

        XCTAssertTrue(container.mainContext.autosaveEnabled)

        NotificationCenter.default.addObserver(
            forName: ModelContext.willSave, object: container.mainContext, queue: nil
        ) { notif in
            Logger.views.error(
                "Received will-save notification: \(notif.userInfo?.debugDescription ?? "<empty>", privacy: .public)"
            )
            Logger.views.error(
                "Received will-save notification: \(notif.debugDescription, privacy: .public)")
        }

        let userResults_preCreate = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults_preCreate.count, 0)

        let authResults_preCreate = try container.mainContext.fetch(
            FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults_preCreate.count, 0)

        let existingUser = User(
            email: "test@example.com", username: "00d66fc4724cad", name: "Test User presave",
            additionalEmails: [], createdAt: Date(), parent: nil, bikes: [])

        let userResults_prefill_postcreate = try container.mainContext.fetch(
            FetchDescriptor<User>())
        XCTAssertEqual(userResults_prefill_postcreate.count, 0)

        let authResults_prefill_postCreate = try container.mainContext.fetch(
            FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults_prefill_postCreate.count, 0)

        container.mainContext.insert(existingUser)

        let existingAuth = AuthenticatedUser(identifier: "456654", bikes: [])

        existingAuth.user = existingUser

        container.mainContext.insert(existingAuth)

        let authResults_post_prefill = try container.mainContext.fetch(
            FetchDescriptor<AuthenticatedUser>())
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
        if let memberships = meResponse.memberships {
            responseUser.organizations = memberships.map { $0.modelInstance() }
        }
        let responseAuthUser = meResponse.modelInstance()

        XCTAssertNil(responseAuthUser.id.storeIdentifier)
        XCTAssertNil(responseAuthUser.user)

        Logger.tests.debug(
            "attaching responseUser to responseAuth - \(String(reflecting: responseUser), privacy: .public)"
        )
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

        XCTAssertEqual(responseAuthUser.user?.createdAt, Date(timeIntervalSince1970: 1_694_235_377))

        XCTAssertNil(responseAuthUser.user?.image)

        let authResults2 = try container.mainContext.fetch(FetchDescriptor<AuthenticatedUser>())
        XCTAssertEqual(authResults2.count, 1)

        let userResults2 = try container.mainContext.fetch(FetchDescriptor<User>())
        XCTAssertEqual(userResults2.count, 1)

    }

}
