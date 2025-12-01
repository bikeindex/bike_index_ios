//
//  AuthViewModelTests.swift
//  UnitTests
//
//  Created by Jack on 11/30/25.
//

import Foundation
import Testing

@testable import BikeIndex

@MainActor
struct AuthViewModelTests {

    @Test func test_signInPageRequest() async throws {
        let authViewModel = AuthView.ViewModel()
        let request = authViewModel.signInPageRequest
        let url = try #require(request.url)

        let urlComponents = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(urlComponents.queryItems?.count == 4)
        let redirectUri = try #require(
            urlComponents.queryItems?.first(where: { $0.name == "redirect_uri" }))
        #expect(redirectUri.value == "bikeindex%3A%2F%2F")
    }

}
