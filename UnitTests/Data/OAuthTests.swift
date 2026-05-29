//
//  OAuthTests.swift
//  UnitTests
//
//  Created by Jack on 11/18/23.
//

import Foundation
import Testing

@testable import BikeIndex

struct OAuthTests {

    @Test func test_oauth_parsing() throws {
        let input = MockData.fullToken
        let rawJsonData = try #require(input.data(using: .utf8))

        let actual = try JSONDecoder().decode(OAuthToken.self, from: rawJsonData)

        #expect(actual.accessToken == "vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY")
        #expect(actual.tokenType == "Bearer")
        #expect(actual.expiresIn == 3_600)
        #expect(actual.refreshToken == "-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM")
        #expect(actual.scope == Scope.allCases)
        #expect(actual.createdAt.timeIntervalSince1970 == 1_698_883_930)
    }

    @Test func oauth_queryItem() {
        #expect(Scope.allCases.queryItem == "read_user+write_user+read_bikes+write_bikes")

        let readOnlyScopes: [Scope] = [.readUser, .readBikes]
        #expect(readOnlyScopes.queryItem == "read_user+read_bikes")

        let writeOnlyScopes: [Scope] = [.writeUser, .writeBikes]
        #expect(writeOnlyScopes.queryItem == "write_user+write_bikes")
    }

    // MARK: OAuthToken encode / decode round-trip tests

    @Test(arguments: [Scope.allCases, [Scope.readUser], []])
    func doMoreThings(scopes: [Scope]) throws {

        let originalToken = OAuthToken(
            accessToken: "tok",
            tokenType: "Bearer",
            expiresIn: 3600,
            refreshToken: "refresh",
            scope: scopes,
            createdAt: Date(timeIntervalSince1970: 1_698_883_930)
        )

        let encoded = try #require(try? JSONEncoder().encode(originalToken))
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OAuthToken.self, from: encoded)

        #expect(decoded.scope.count == scopes.count)
        #expect(decoded.scope == scopes)
    }

}
