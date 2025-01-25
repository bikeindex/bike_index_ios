//
//  BikeIndexTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/18/23.
//

import XCTest

@testable import BikeIndex

final class OAuthTests: XCTestCase {

    func test_oauth_parsing() throws {
        let input = MockData.fullToken
        let rawJsonData = input.data(using: .utf8).unsafelyUnwrapped
        let output = try JSONDecoder().decode(OAuthToken.self, from: rawJsonData)

        XCTAssertEqual(output.accessToken, "vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY")
        XCTAssertEqual(output.tokenType, "Bearer")
        XCTAssertEqual(output.expiresIn, 3_600)
        XCTAssertEqual(output.refreshToken, "-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM")
        XCTAssertEqual(output.scope, Scope.allCases)
        XCTAssertEqual(output.createdAt.timeIntervalSince1970, 1_698_883_930)

    }
}
