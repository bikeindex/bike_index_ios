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
        let rawJsonData = input.data(using: .utf8).unsafelyUnwrapped
        let output = try JSONDecoder().decode(OAuthToken.self, from: rawJsonData)

        #expect(output.accessToken == "vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY")
        #expect(output.tokenType == "Bearer")
        #expect(output.expiresIn == 3_600)
        #expect(output.refreshToken == "-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM")
        #expect(output.scope == Scope.allCases)
        #expect(output.createdAt.timeIntervalSince1970 == 1_698_883_930)
    }

    @Test func test_oauth_queryItem() {
        #expect(Scope.allCases.queryItem == "read_user+write_user+read_bikes+write_bikes")

        let readOnlyScopes: [Scope] = [.readUser, .readBikes]
        #expect(readOnlyScopes.queryItem == "read_user+read_bikes")

        let writeOnlyScopes: [Scope] = [.writeUser, .writeBikes]
        #expect(writeOnlyScopes.queryItem == "write_user+write_bikes")
    }
}
