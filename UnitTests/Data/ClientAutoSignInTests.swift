//
//  ClientAutoSignInTests.swift
//  UnitTests
//
//  Verifies the automatic sign-in-on-launch behavior: a token persisted in the keychain is
//  restored synchronously when valid, and refreshed (then re-persisted) when expired.
//

import Foundation
import KeychainSwift
import Testing

@testable import BikeIndex

@MainActor
final class ClientAutoSignInTests {
    /// A keychain stub subclass that stores values in memory and can be pre-seeded with a token.
    final class StubKeychain: KeychainSwift, @unchecked Sendable {
        private let lock = NSLock()
        private var store: [String: String] = [:]

        init(preloaded: [String: String] = [:]) {
            store = preloaded
            super.init()
        }

        override func get(_ key: String) -> String? {
            lock.lock()
            defer { lock.unlock() }
            return store[key]
        }

        override func delete(_ key: String) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            let existed = store.removeValue(forKey: key) != nil
            return existed
        }
    }

    @Test func valid_persisted_token_restores_session_synchronously() throws {
        let validToken = OAuthToken.newToken(expiresIn: 3600)
        let data = try JSONEncoder().encode(validToken)
        let keychain = StubKeychain(
            preloaded: ["oauthToken": String(decoding: data, as: UTF8.self)])

        let client = try Client(keychain: keychain, restoreSession: true)

        #expect(client.isRestoringSession == false)
        #expect(client.auth == validToken)
        #expect(client.accessToken == validToken.accessToken)
        #expect(client.authenticated)
    }

    @Test func missing_keychain_token_shows_nothing() throws {
        let client = try Client(keychain: StubKeychain(), restoreSession: true)

        #expect(client.auth == nil)
        #expect(client.accessToken == nil)
        #expect(client.authenticated == false)
        #expect(client.isRestoringSession == false)
    }

    @Test func corrupt_keychain_token_is_ignored() throws {
        let keychain = StubKeychain(preloaded: ["oauthToken": "{not json"])

        let client = try Client(keychain: keychain, restoreSession: true)

        #expect(client.auth == nil)
        #expect(client.authenticated == false)
        #expect(client.isRestoringSession == false)
    }

    @Test func expired_persisted_token_enters_restoring_state() throws {
        // Created in the distant past, so `expiration` is in the past.
        let expiredToken = OAuthToken(
            accessToken: "expired-access",
            tokenType: "Bearer",
            expiresIn: 60,
            refreshToken: "expired-refresh",
            scope: Scope.allCases,
            createdAt: Date(timeIntervalSince1970: 1_000_000_000))
        let data = try JSONEncoder().encode(expiredToken)
        let keychain = StubKeychain(
            preloaded: ["oauthToken": String(decoding: data, as: UTF8.self)])

        let client = try Client(keychain: keychain, restoreSession: true)

        // The expired token is not treated as an authenticated session…
        #expect(client.authenticated == false)
        // …but the client immediately attempts a refresh and reports so to the UI.
        #expect(client.isRestoringSession == true)
        // The in-memory session is not populated with the stale token.
        #expect(client.auth == nil)
    }

    @Test func setupRefreshTimer_enforces_15_second_minimum() throws {
        // Token that expires in 20 seconds → (expiration - 15) = 5s → clamped to 15s
        let shortLivedToken = OAuthToken.newToken(expiresIn: 20)
        let client = try Client(keychain: StubKeychain(), restoreSession: false)
        client.auth = shortLivedToken
        client.setupRefreshTimer()

        #expect(client.refreshTimer != nil, "Refresh timer should be scheduled")
        // The timer's fireDate should be at least 15 seconds in the future.
        let remaining = client.refreshTimer!.fireDate.timeIntervalSinceNow
        // small tolerance for clock granularity
        #expect(
            remaining >= 14,
            "Timer should fire at least ~15s from now (clamped minimum), got \(remaining)s")

        // Token that expires in 3600 seconds → (expiration - 15) = 3585s → not clamped
        let longLivedToken = OAuthToken.newToken(expiresIn: 3600)
        client.auth = longLivedToken
        client.setupRefreshTimer()

        #expect(client.refreshTimer != nil, "Refresh timer should be re-scheduled")
        let longRemaining = client.refreshTimer!.fireDate.timeIntervalSinceNow
        #expect(
            longRemaining > 15,
            "Long-lived token should produce a timer well above 15s, got \(longRemaining)s")

        // Clean up
        client.refreshTimer?.invalidate()
    }

    @Test func setupRefreshTimer_no_op_without_auth() throws {
        let client = try Client(keychain: StubKeychain(), restoreSession: false)

        #expect(client.auth == nil)
        #expect(client.refreshTimer == nil)

        // Should not crash or schedule anything
        client.setupRefreshTimer()

        #expect(client.refreshTimer == nil)
    }

    @Test func restoreSession_disabled_skips_keychain() throws {
        let validToken = OAuthToken.newToken(expiresIn: 3600)
        let data = try JSONEncoder().encode(validToken)
        let keychain = StubKeychain(
            preloaded: ["oauthToken": String(decoding: data, as: UTF8.self)])

        let client = try Client(keychain: keychain, restoreSession: false)

        #expect(client.auth == nil)
        #expect(client.authenticated == false)
        #expect(client.isRestoringSession == false)
    }
}
