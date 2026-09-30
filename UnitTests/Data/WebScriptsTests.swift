//
//  WebScriptsTests.swift
//  UnitTests
//
//  Verifies that the org-dependent `hideNav` WKUserScript is registered only for a
//  *known* non-org user, never for an unknown (pre-profile) or org user.
//

import Foundation
import Testing
import WebKit

@testable import BikeIndex

@MainActor
final class WebScriptsTests {
    private func containsHideNav(_ controller: WKUserContentController) -> Bool {
        controller.userScripts.contains { $0.source.contains("nav { display: none }") }
    }

    private func makeClient() throws -> Client {
        try Client(keychain: ClientAutoSignInTests.StubKeychain(), restoreSession: false)
    }

    @Test func hideNav_not_registered_for_unknown_or_org_user() throws {
        let client = try makeClient()
        let controller = client.webConfiguration.userContentController

        // Unknown (nil) org state — e.g. before `fetchProfile` — must not hide the nav.
        client.userIsInOrganization = nil
        client.registerUserScripts()
        #expect(!containsHideNav(controller), "hideNav must not be added while unknown")

        // A known org user must not have the nav hidden (they need it for the org menu).
        client.userIsInOrganization = true
        client.registerUserScripts()
        #expect(!containsHideNav(controller), "hideNav must not be added for an org user")
    }

    @Test func hideNav_registered_for_known_non_org_user() throws {
        let client = try makeClient()
        let controller = client.webConfiguration.userContentController

        client.userIsInOrganization = false
        client.registerUserScripts()
        #expect(containsHideNav(controller), "hideNav must be added for a non-org user")
    }

    @Test func invalidating_session_clears_hide_nav() throws {
        let client = try makeClient()
        let controller = client.webConfiguration.userContentController

        // Simulate a non-org sign-in that registered hideNav…
        client.userIsInOrganization = false
        client.registerUserScripts()
        #expect(containsHideNav(controller))

        // …then a sign-out. `invalidateAuth` must clear the flag and drop hideNav so it
        // can't leak into a subsequent org user's session.
        client.invalidateAuth()
        #expect(client.userIsInOrganization == nil)
        #expect(!containsHideNav(controller), "hideNav must be cleared on sign-out")
    }
}
