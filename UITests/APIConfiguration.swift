//
//  APIConfiguration.swift
//  UITests
//
//  Created by Jack on 9/6/26.
//

import Foundation
import XCTest

/// Used ONLY for UITests
struct APIConfiguration {
    let host: URL
    let port: UInt16

    static func uiTestConfig() throws -> Self {
        let uiTestBundle = try XCTUnwrap(Bundle.uiTests)
        let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)

        let hostString = try XCTUnwrap(
            (infoDictionary["API_HOST"] as? String)?
                .replacing("\\/\\/", with: "//")
        )
        var host = try XCTUnwrap(URL(string: hostString))
        let portString = try XCTUnwrap(infoDictionary["API_PORT"] as? String)
        let port = try XCTUnwrap(UInt16(portString))

        if port != 443 {
            host = try XCTUnwrap(URL(string: hostString + ":\(port)"))
        }

        return Self(host: host, port: port)
    }

    private init(host: URL, port: UInt16) {
        self.host = host
        self.port = port
    }
}
