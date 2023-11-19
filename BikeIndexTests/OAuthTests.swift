//
//  BikeIndexTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/18/23.
//

import XCTest

final class OAuthTests: XCTestCase {

    func testOAuthParsing() throws {
        let input = """
{"access_token":"vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY","token_type":"Bearer","expires_in":3600,"refresh_token":"-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM","scope":"read_user write_user read_bikes write_bikes read_organization_membership write_organizations","created_at":1698883930}
"""

        let rawJsonData = input.data(using: .utf8).unsafelyUnwrapped
        let output = try JSONDecoder().decode(Auth.self, from: rawJsonData)

        XCTAssertEqual(output.accessToken, "vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY")
        XCTAssertEqual(output.tokenType, "Bearer")
        XCTAssertEqual(output.expiresIn, 3_600)
        XCTAssertEqual(output.refreshToken, "-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM")
        XCTAssertEqual(output.scope, Scope.allCases)
        XCTAssertEqual(output.createdAt.timeIntervalSince1970, 1698883930)

    }
}
