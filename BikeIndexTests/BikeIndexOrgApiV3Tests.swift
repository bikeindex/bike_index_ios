//
//  BikeIndexOrgApiV3Tests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/22/23.
//

import XCTest

final class BikeIndexOrgApiV3Tests: XCTestCase {
    func test_v3_bikes() {
        let token = UUID().uuidString
        let config = EndpointConfiguration(accessToken: token,
                                           host: URL(string: "https://bikeindex.org/api/v3/bikes")!)

        let identifier = "0987654321"
        let path = BikeIndexV3.Bikes.bikes(identifier: identifier)

        let endpoint = Endpoint(path: path, config: config)

        XCTAssertEqual(endpoint.request.url.unsafelyUnwrapped.absoluteString,
                       "https://bikeindex.org/api/v3/bikes/\(identifier)?accessToken=\(token)")
    }
}
