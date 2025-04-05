//
//  AuthInterceptorTests.swift
//  UnitTests
//
//  Created by Jack on 3/30/25.
//

import Foundation
import Testing
import WebKit
@testable import BikeIndex

/// Tests for
struct AuthInterceptorTests {

    let hostProvider = HostProvider(host: URL("https://bikeindex.org"))

    /// `AuthenticationNavigator.Interceptor` SHOULD intercept /session/new URLs
    /// to make sure the sign-in flow always displays an app-functional page.
    @Test(arguments:
            ["https://bikeindex.org/session/new",
             "https://bikeindex.org/session/new?return_to=%2Fbikes%2FA40340%2Fscanned%3Forganization_id%3D2167",
             "bikeindex://https://bikeindex.org/session/new"])
    func test_redirect_web_signin_to_app(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let output = interceptor.filterSignInRedirect(input)
        try #require(output != nil)
        #expect(output == WKNavigationActionPolicy.cancel)
    }

    /// `AuthenticationNavigator.Interceptor` should NOT intercept other URLs
    @Test(arguments: ["invalid_url",
                      "https://bikeindex.org/help", ])
    func test_redirect_web_signing_irrelevant_url(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let output = interceptor.filterSignInRedirect(input)
        try #require(output == nil)
    }
}
