//
//  Client.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import OSLog
import SwiftData
import Combine
import KeychainSwift
import URLEncodedForm

/// Instances created by Client at runtime to provide the full information for EndpointProvider instances.
/// This allows safe API access.
protocol EndpointConfigurationProvider {
    var accessToken: Token? { set get }
    var host: URL { get }
}

/// Instance of EndpointConfigurationProvider
struct EndpointConfiguration: EndpointConfigurationProvider {
    var accessToken: Token?
    let host: URL
}

/// Convenience wrapper to shuttle query items from an array of string-tuples into actual `URLQueryItem` objects.
typealias QueryItemTuple = (name: String, value: String)

/// Stateful API client for interacting with bikeindex.org
/// Wraps ``API`` class.
/// Controls networking state and loads app configuration from the bundle.
@Observable class Client {
    private let session = URLSession(configuration: .default)

    private(set) var configuration: ClientConfiguration
    private(set) var api: API

    /// Full OAuth token response.
    private(set) var auth: OAuthToken?
    /// Access token is provided by the OAuth flow to the application from `ASWebAuthenticationSession`.
    /// The access token may be required in requests and it may be used to retrieve the full OAuth token (see ``auth``).
    private var accessToken: Token?
    private var keychain = KeychainSwift()
    private var subscriptions: [AnyCancellable] = []

    init(keychain: KeychainSwift = KeychainSwift()) throws {
        self.keychain = keychain
        let configuration = try ClientConfiguration.bundledConfig()
        self.api = API(configuration: EndpointConfiguration(accessToken: "",
                                                            host: configuration.host),
                       session: session)
        self.configuration = configuration
        loadLastToken()
    }

    struct Constants {
        /// Extract access token from OAuth flow stored in the value of this query paremter
        static let code = "code"

        /// Write access token into authenticated requests with this query parameter
        static let accessToken = "access_token"
    }

    private struct Keychain {
        /// Identifier to key a full Auth object in the keychain
        static let oauthToken = "oauthToken"
    }

    /// Load any persisted OAuth Token and attempt to use it to continue the last session.
    private func loadLastToken() {
        if let lastKnownToken = KeychainSwift().get(Keychain.oauthToken),
           let rawData = lastKnownToken.data(using: .utf8) {
            do {
                let lastKnownAuth = try JSONDecoder().decode(OAuthToken.self, from: rawData)
                guard lastKnownAuth.isValid else {
                    return
                }
                self.auth = lastKnownAuth
                accessToken = lastKnownAuth.accessToken
                self.api.configuration.accessToken = lastKnownAuth.accessToken
                Logger.api.debug("Client.\(#function) found existing valid token \(String(describing: lastKnownAuth), privacy: .private)")
            } catch {
                Logger.api.debug("Failed to find existing auth")
            }
        }
    }

    /// Allow users to log out
    func destroySession() {
        KeychainSwift().delete(Keychain.oauthToken)
        accessToken = nil
        auth = nil
        api = API(configuration: EndpointConfiguration(accessToken: "",
                                                       host: configuration.host),
                  session: session)
    }

    var userCanRegisterBikes: Bool {
        configuration.oauthScopes.contains(Scope.writeBikes)
    }
}

// MARK: - Authentication Operations

extension Client {

    /// Stateful function to receive results of an authentication result.
    /// - Parameter authCallback: The "redirect URI" received from the OAuth provider. This should contain relevant
    /// query parameters to continue with a valid session. This *must* contain a `code` query paramter which will be
    /// forwarded to the ``OAuth.token`` endpoint.
    /// - Returns: True if processing proceeded normally. False if any errors occurred.
    @discardableResult func accept(authCallback: URL) async -> Bool {
        let components = URLComponents(string: authCallback.absoluteString)
        guard let queryItems = components?.queryItems,
              let code = queryItems.first(where: { $0.name == Constants.code }),
              let newToken = code.value else {
            Logger.api.debug("\(#function) exiting for lack of query item 'code'")
            return false
        }
        accessToken = newToken

        let tokenQuery = [
            ("client_id", configuration.clientId),
            ("client_secret", configuration.secret),
            ("code", newToken),
            ("grant_type", "authorization_code"),
            ("redirect_uri", configuration.redirectUri)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }

        let fullToken = await api.get(OAuth.token(queryItems: tokenQuery))
        switch fullToken {
        case .success(let success):
            guard let fullTokenAuth = success as? OAuthToken else {
                return false
            }
            self.auth = fullTokenAuth
            self.api.configuration.accessToken = fullTokenAuth.accessToken
            do {
                let data = try JSONEncoder().encode(fullTokenAuth)
                self.keychain.set(data, forKey: Keychain.oauthToken)
            } catch {
                Logger.client.error("Failed to persist /oauth/token to keychain after fetching successfully, continuing")
            }
        case .failure(let failure):
            Logger.client.error("Failed to fetch /oauth/token \(failure)")
            return false
        }

        return true
    }

    /// Inform any `@State` watchers if the authentication is valid or has become void.
    var authenticated: Bool {
        if let auth {
            auth.isValid
        } else {
            false
        }
    }
}

// MARK: Global Bike Search queries

extension Client {
    @available(*, deprecated, message: "Migrate to API for stateless and abstract network operations")
    func queryGlobal(context: ModelContext) {
        Logger.api.critical("\(#function) has been removed until it can be replaced.")
    }
}
