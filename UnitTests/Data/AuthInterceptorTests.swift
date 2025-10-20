//
//  AuthInterceptorTests.swift
//  UnitTests
//
//  Created by Jack on 3/30/25.
//

import Foundation
import OSLog
import Testing
import WebKit

@testable import BikeIndex

/// Tests for
@MainActor
struct AuthInterceptorTests {

    let hostProvider = HostProvider(host: URL("https://bikeindex.org"))

    // MARK: Universal Links

    /// `AuthenticationNavigator.Interceptor` must intercept `/session/new?return_to` URLs
    /// to make sure the Universal Link to Sign-In flow always displays an app-functional page.
    @Test(arguments: [
        "https://bikeindex.org/session/new?return_to=%2Fbikes%2FA40340%2Fscanned%3Forganization_id%3D1234"
    ])
    func test_redirect_web_signin_to_app(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let output = interceptor.filterSignInRedirect(input)
        try #require(output != nil)
        #expect(output == WKNavigationActionPolicy.cancel)
    }

    /// `AuthenticationNavigator.Interceptor` must NOT intercept `/session/new` (without query parameters) to make
    /// sure the sign-in flow always displays an app-functional page.
    /// `AuthenticationNavigator.Interceptor` must NOT intercept other URLs
    @Test(arguments: [
        "https://bikeindex.org/session/new",
        "bikeindex://https://bikeindex.org/session/new",  // not necessary in production
        "invalid_url",
        "https://bikeindex.org/help",
    ])
    func test_redirect_web_signing_irrelevant_url(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let output = interceptor.filterSignInRedirect(input)
        try #require(output == nil)
    }

    // MARK: Regular Authentication WebView Navigation Links

    /// Authentication-completed deeplinks must be intercepted
    @Test(arguments: ["bikeindex://?code=edf1d0dec505adfd97e89ad2b76c2e71"])
    func test_webview_redirect(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let mockClient = try MockClient()
        let output = await interceptor.filterCompletedAuthentication(
            input,
            client: mockClient)
        try #require(output != nil)
        #expect(output == WKNavigationActionPolicy.cancel)
        let accessToken = try #require(mockClient.accessToken)
        #expect(accessToken == rawInput.split(separator: "=")[1])
    }

    /// Authentication page must be presented **before** any sign-in has started and **not** intercepted.
    @Test(arguments: [
        "https://bikeindex.org/oauth/authorize?client_id=0987654321&response_type=code&redirect_uri=bikeindex://&scope=read_user+write_user+read_bikes+write_bikes"
    ])
    func test_webview_redirect_non_intercepted(rawInput: String) async throws {
        let input = try #require(URL(string: rawInput))
        let interceptor = AuthenticationNavigator.Interceptor(hostProvider: hostProvider)
        let mockClient = try Client()
        let output = await interceptor.filterCompletedAuthentication(
            input,
            client: mockClient)
        try #require(output == nil)
    }

}

class MockClient: Client {
    /// `test_webview_redirect()` will invoke `accept(authCallback:)` with a mocked authorization code.
    /// The regular Client implementation will try to fetch the full token and that will always fail in these tests.
    override func accept(authCallback: URL) async -> Bool {
        guard let scheme = authCallback.scheme, scheme + "://" == configuration.redirectUri else {
            Logger.api.debug(
                "\(#function) exiting because \(authCallback.scheme ?? "", privacy: .sensitive) does not match the redirectUri"
            )
            return false
        }

        let components = URLComponents(string: authCallback.absoluteString)
        guard let queryItems = components?.queryItems,
            let code = queryItems.first(where: { $0.name == Constants.code }),
            let newToken = code.value
        else {
            Logger.api.debug(
                "\(#function) exiting for lack of query item 'code' from callback \(authCallback, privacy: .sensitive)"
            )
            return false
        }
        accessToken = newToken
        return true
    }
}
