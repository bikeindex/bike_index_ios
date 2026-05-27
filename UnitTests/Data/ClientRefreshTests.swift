//
//  ClientRefreshTests.swift
//  UnitTests
//
//  Created by Jack on 2/17/24.
//

import OSLog
import Testing

@testable import BikeIndex

@MainActor
final class ClientRefreshTests {
    var client: TestableClient!

    @Test func token_renewal_via_setupRefreshTimer() async throws {
        let expirationInterval: TimeInterval = 15
        let responseToken = OAuthToken.newToken(expiresIn: expirationInterval)

        client = try TestableClient()
        client.setAuth(responseToken)
        client.accessToken = client.auth?.accessToken
        let originalToken = try #require(client.accessToken)
        let tokenIsValid = client.auth?.isValid ?? false
        #expect(tokenIsValid)
        #expect(client.auth?.expiration == responseToken.expiration)

        try await confirmation { didRefresh in
            Logger.tests.debug("\(#function) start timer")
            client.setupRefreshTimer()
            try await Task.sleep(for: .seconds(expirationInterval + 1))

            let newToken = try #require(client.accessToken)
            Logger.tests.debug("\(#function) comparing tokens")
            #expect(originalToken != newToken, "Tokens must be different after refresh")
            didRefresh.confirm()
        }
    }

    deinit {
        Task { [weak client] in
            await client?.destroySession()
        }
    }
}

/// Additional behavior to enable testing without reaching out to a server
class TestableClient: Client {
    func setAuth(_ token: OAuthToken) {
        Logger.tests.info(
            "TestableClient assigned new setAuth to \(String(describing: token), privacy: .public)")

        self.auth = token
        self.accessToken = auth?.accessToken
    }

    @objc override func refreshToken(timer: Timer) {
        self.auth = OAuthToken.newToken(expiresIn: 60)
        self.accessToken = auth?.accessToken
        Logger.tests.info(
            "Received refreshToken invocation, assigned new auth \(String(describing: self.auth))")
    }
}

extension OAuthToken {
    static func newToken(expiresIn: TimeInterval) -> OAuthToken {
        OAuthToken(
            accessToken: UUID().uuidString,
            tokenType: "Bearer",
            expiresIn: expiresIn,
            refreshToken: UUID().uuidString,
            scope: Scope.allCases,
            createdAt: Date())
    }
}
