//
//  AuthViewModel.swift
//  BikeIndex
//
//  Created by Jack on 3/19/25.
//

import Foundation
import SwiftUI

extension ClientConfiguration {
    fileprivate var authorizeQueryItems: [URLQueryItem] {
        return [
            ("client_id", clientId),
            ("response_type", "code"),
            ("redirect_uri", redirectUri),
            ("scope", oauthScopes.queryItem),
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
    }
}

extension AuthView {
    @MainActor @Observable
    final class ViewModel {
        /// Control presenting a modal sheet for app authorization
        var display: Bool = false

        /// Object to intercept authentication events from the sign-in WebView and forward them to Client
        /// ``AuthenticationNavigator/client`` must be connected at runtime so that AuthNavigator can update ``Client``
        /// with authorization events.
        let historyNavigator: HistoryNavigator
        var authNavigator: AuthenticationNavigator

        /// AuthView may push to a Debug view (debug builds only)
        var topLevelPath = NavigationPath()

        @ObservationIgnored
        var configuration = try! ClientConfiguration.bundledConfig()

        init() {
            let configuration = try! ClientConfiguration.bundledConfig()
            let authNavigator = AuthenticationNavigator(
                interceptor: .init(hostProvider: configuration.hostProvider))
            let historyNavigator = HistoryNavigator(child: authNavigator)
            self.authNavigator = authNavigator
            self.historyNavigator = historyNavigator
            self.configuration = configuration
        }

        // MARK: - NavigationPath

        /// Destinations to go to **outside** of AuthView/onboarding
        enum Nav: Identifiable {
            var id: Self { self }

            case debugSettings
            case help
        }

        /// URL helper to find the right user-facing authorization page for this app config.
        var signInPageRequest: URLRequest {
            OAuth.authorize(queryItems: configuration.authorizeQueryItems).request(
                for: configuration.hostProvider
            )
        }
    }
}
