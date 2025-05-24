//
//  AppVersionInfoTests.swift
//  UnitTests
//
//  Created by Jack on 5/24/25.
//

import Testing
@testable import BikeIndex

struct AppVersionInfoTests {

    @Test func test_versionInfo() async throws {
        let appVersionInfo = AppVersionInfo()
        let marketingVersion = try #require(appVersionInfo.marketingVersion)

        let buildNumber = try #require(appVersionInfo.buildNumber)
        #expect(Int(buildNumber) != nil, "Build number must be an integer. Found \(buildNumber)")

        #expect(appVersionInfo.referralSource != "app-ios")
        #expect(appVersionInfo.referralSource.hasSuffix(marketingVersion), "Referral source should end with the marketing version.")
        #expect(appVersionInfo.referralSource.hasPrefix("app-ios"), "Referral source must have app-ios prefix.")
    }

}
