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
        var display: Sheet? {
            didSet {
                switch display {
                case .displaySignIn:
                    navigationUrl = oAuthUrl.unsafelyUnwrapped
                case .deeplink(let url):
                    navigationUrl = url
                case nil:
                    navigationUrl = URL("about:blank")
                }
            }
        }

        var navigationUrl: URL = URL("about:blank")

        /// Object to intercept authentication events from the sign-in WebView and forward them to Client
        /// ``AuthenticationNavigator/client`` must be connected at runtime so that AuthNavigator can update ``Client``
        /// with authorization events.
        let authNavigator = AuthenticationNavigator()

        /// AuthView may push to a Debug view (debug builds only)
        var topLevelPath = NavigationPath()

        @ObservationIgnored
        var configuration = try! ClientConfiguration.bundledConfig()

        // MARK: - NavigationPath

        /// Destinations to go to **outside** of AuthView/onboarding
        enum Nav: Identifiable {
            var id: Self { self }

            case debugSettings
            case help
        }

        /// Destinations to present **within** AuthView
        enum Sheet: Hashable, Identifiable {
            var id: Self { self }

            case displaySignIn
            case deeplink(url: URL)
        }

        /// URL helper to find the right user-facing authorization page for this app config.
        private var oAuthUrl: URL? {
            // TODO: Make this easier to work with -- separate Client (runtime state) from Configuration (bundled values)
            OAuth.authorize(queryItems: configuration.authorizeQueryItems).request(
                for: EndpointConfiguration(host: configuration.host)
            ).url
        }
    }
}
