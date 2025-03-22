//
//  BikeIndexOrgApiV3Tests.swift
//  UnitTests
//
//  Created by Jack on 11/22/23.
//

import XCTest

@testable import BikeIndex

final class BikeIndexOrgApiV3Tests: XCTestCase {
    func test_v3_bikes() throws {
        let config = HostProvider(
            host: URL("https://bikeindex.org/"))

        let identifier = 0_987_654_321
        let path = Bikes.bikes(identifier: identifier)

        let endpoint = path.request(for: config)
        let url = try XCTUnwrap(endpoint.url)

        XCTAssertEqual(
            url.absoluteString,
            "https://bikeindex.org/api/v3/bikes/\(identifier)")
    }
}
