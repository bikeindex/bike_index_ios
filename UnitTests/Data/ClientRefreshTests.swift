//
//  ClientRefreshTests.swift
//  UnitTests
//
//  Created by Jack on 2/17/24.
//

import OSLog
import XCTest

@testable import BikeIndex

enum TestableState {
    case unauthenticated
    case authenticated
    case renewing/// aka expired
}

/// Additional behavior to enable testing
class TestableClient: Client {
    var state: TestableState = .unauthenticated

    func setAuth(_ token: OAuthToken) {
        Logger.tests.info(
            "TestableClient assigned new setAuth to \(String(describing: token), privacy: .public)")

        self.auth = token
        self.state = .authenticated
    }

    @objc override func refreshToken(timer: Timer) {
        Logger.tests.info("Received refreshToken invocation")
        self.state = .renewing

        guard let userInfo = timer.userInfo as? [String: AnyObject] else {
            Logger.tests.fault("Failed to extract user info from timer \(timer, privacy: .public)")
            return
        }

        if let token = userInfo["token"] as? OAuthToken {
            // Mimic behavior of sending network request, receiving refreshed token
            self.auth = token
        }
        if let expectation = userInfo["expectation"] as? XCTestExpectation {
            expectation.fulfill()
        }
    }
}

// MARK: -

@MainActor
final class ClientRefreshTests: XCTestCase {
    var client: TestableClient!

    override func setUpWithError() throws {
        self.client = try TestableClient()
    }

    override func tearDownWithError() throws {
        Task { [weak client] in
            await client?.destroySession()
        }
    }

    func test_token_renewal() throws {
        let waiter = XCTWaiter()
        let expirationInterval: TimeInterval = 5

        let input = MockData.fullToken
            .replacingOccurrences(of: "3600", with: String(expirationInterval))
        let inputData = try XCTUnwrap(input.data(using: .utf8))
        let responseToken = try JSONDecoder().decode(OAuthToken.self, from: inputData)

        client.setAuth(responseToken)
        XCTAssertEqual(client.state, .authenticated)

        let expectation = XCTestExpectation(
            description: "Token renewal must activate a refresh request")

        // NEW token
        let newAccessToken = UUID().uuidString
        let newRefreshToken = UUID().uuidString
        let newToken = OAuthToken(
            accessToken: newAccessToken,
            tokenType: "Bearer",
            expiresIn: expirationInterval + 1,
            refreshToken: newRefreshToken,
            scope: Scope.allCases,
            createdAt: Date())

        Logger.tests.info("starting waiter")

        let safeClient = try XCTUnwrap(client)
        let timer = Timer(
            timeInterval: expirationInterval,
            target: safeClient,
            selector: #selector(safeClient.refreshToken(timer:)),
            userInfo: [
                "token": newToken,
                "expectation": expectation,
            ],
            repeats: false)
        safeClient.refreshRunLoop.add(
            timer,
            forMode: .default)
        safeClient.refreshTimer = timer

        Logger.tests.info("Expectation is \(expectation)")
        let result = waiter.wait(
            for: [expectation],
            timeout: expirationInterval * 2)

        switch result {
        case .timedOut:
            XCTFail("The timer could not complete correctly")
        default:
            break
        }
    }
}
