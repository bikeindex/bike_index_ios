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

typealias QueryItemTuple = (name: String, value: String)

/// API client for interacting with bikeindex.org
@Observable class Client {
    private let session = URLSession(configuration: .default)

    private(set) var configuration: ClientConfiguration

    /// Full OAuth token response.
    var auth: Auth?
    /// Access token is provided by the OAuth flow to the application from `ASWebAuthenticationSession`.
    /// The access token may be required in requests and it may be used to retrieve the full OAuth token (see ``auth``).
    var accessToken: Token?

    private var keychain = KeychainSwift()

    private var subscriptions: [AnyCancellable] = []

    init(keychain: KeychainSwift = KeychainSwift()) throws {
        self.keychain = keychain
        try self.configuration = ClientConfiguration.bundledConfig()

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

    private func loadLastToken() {
        if let lastKnownToken = KeychainSwift().get(Keychain.oauthToken),
           let rawData = lastKnownToken.data(using: .utf8) {
            do {
                let lastKnownAuth = try JSONDecoder().decode(Auth.self, from: rawData)
                guard lastKnownAuth.isValid else {
                    return
                }
                self.auth = lastKnownAuth
                accessToken = lastKnownAuth.accessToken
            } catch {
                Logger.api.debug("Failed to find existing auth")
            }
        }
    }

    func destroySession() {
        KeychainSwift().delete(Keychain.oauthToken)
        accessToken = nil
        auth = nil
    }
}

// MARK: - Authentication Operations

extension Client {
    @discardableResult func accept(authCallback: URL) -> Bool {
        Logger.api.debug("\(#function) enter")
        let components = URLComponents(string: authCallback.absoluteString)
        guard let queryItems = components?.queryItems,
              let code = queryItems.first(where: { $0.name == Constants.code }) else {
            Logger.api.debug("\(#function) exiting for lack of query item")
            return false
        }

        if let newToken = code.value {
            accessToken = newToken
            fetchFull(token: newToken)
            return true
        }

        Logger.api.debug("\(#function) exiting false for lack of code.value from \(authCallback)")
        return false
    }

    /// https://bikeindex.org/documentation/api_v3#ref_oauth
    private func fetchFull(token: Token) {
        Logger.api.debug("\(#function) enter")
        var url = configuration.host.appending(path: "oauth/token")

        let queryItems: [URLQueryItem] = [
            ("client_id", configuration.clientId),
            ("client_secret", configuration.secret),
            ("code", token),
            ("grant_type", "authorization_code"),
            ("redirect_uri", configuration.redirectUri)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let authCancellable = session.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    Logger.api.debug("Received network response other than 200.")
                    Logger.api.debug("requsted url \(url)")
                    Logger.api.debug("received data: \(element.data)")
                    Logger.api.debug("received data: \(element.response)")

                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Auth.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { Logger.api.debug("\(#function) received completion: \(String(describing: $0)) ")},
                  receiveValue: { auth in
                self.auth = auth
                do {
                    let data = try JSONEncoder().encode(auth)
                    self.keychain.set(data, forKey: Keychain.oauthToken)
                } catch {
                    Logger.api.error("Failed to persist \(error)")
                }
            })

        authCancellable.store(in: &subscriptions)
    }

    var authenticated: Bool {
        auth != nil
    }
}

// MARK: - Profile Operations

extension Client {
    /// Fetch the full profile information of the currently authenticated user, cache it,
    /// and allow the UI to be udpated from this change.
    func fetchProfile(context: ModelContext) {
        Logger.api.debug("\(#function) enter, auth?.accessToken \(String(describing: self.auth?.accessToken))")
        guard let oauthToken = auth?.accessToken else {
            return
        }

        var url = configuration.host.appendingPathComponent("api/v3/me")
        url.append(queryItems: [
            URLQueryItem(name: Constants.accessToken, value: oauthToken)
        ])

        let cancellable = session
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {

                    Logger.api.debug("Received network response other than 200.")
                    Logger.api.debug("requsted url \(url)")
                    Logger.api.debug("received data: \(element.data)")
                    Logger.api.debug("received data: \(element.response)")

                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: AuthenticatedUser.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { Logger.api.debug("\(#function) Received completion: \(String(describing: $0)).") },
                  receiveValue: { authenticatedUser in

                let authenticatedIdentifier = authenticatedUser.identifier
                do {
                    try context.delete(model: AuthenticatedUser.self, where: #Predicate { user in
                        user.identifier != authenticatedIdentifier
                    })
                } catch {
                    Logger.api.error("Failed to remove authenticated users from database \(error)")
                }

                context.insert(authenticatedUser)
            })

        cancellable.store(in: &subscriptions)
    }
}

// MARK: - Bike Query Operations

extension Client {
    func fetch(bike: UInt, context: ModelContext) {
        Logger.api.debug("\(#function) enter")

        var url = configuration.host.appending(path: "api/v3/bikes")
        url.append(path: String(bike))
        url.append(queryItems: [
            URLQueryItem(name: Constants.accessToken, value: auth?.accessToken),
        ])

        let cancellable = session
            .dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {

                    Logger.api.debug("Received network response other than 200.")
                    Logger.api.debug("requsted url \(url)")
                    Logger.api.debug("received data: \(element.data)")
                    Logger.api.debug("received data: \(element.response)")
                    throw URLError(.badServerResponse)
                }

                return element.data
            }
            .decode(type: ResponseBike.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { Logger.api.debug("\(#function) Received completion: \(String(describing: $0)).") },
                  receiveValue: { response in
                Logger.api.debug("\(#function) Received response: \(response.bike.identifier)")
                context.insert(response.bike)
            })

        cancellable.store(in: &subscriptions)
    }
}

// MARK: - Autocomplete Queries

extension Client {
    /// Queries https://bikeindex.org/api/autocomplete?per_page=10&categories=frame_mnfg&q=search_term
    func query(manufacturer name: String,
               pageSize: Int = 10,
               context: ModelContext) {
        Logger.api.debug("\(#function) enter")

        var url = configuration.host.appendingPathComponent("api/autocomplete")
        url.append(queryItems: [
            URLQueryItem(name: "per_page", value: String(pageSize)),
            URLQueryItem(name: "categories", value: "frame_mnfg"),
            URLQueryItem(name: "q", value: name)
        ])

        let cancellable = session
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    Logger.api.debug("\(#function) response other than 200 from \(element.response)")
                    Logger.api.debug("\(#function) response other than 200 with data \(element.data)")
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: AutocompleteResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { Logger.api.debug("\(#function) Received completion: \(String(describing: $0)).") },
                  receiveValue: { response in

                response.matches.forEach {
                    context.insert($0)
                }
            })

        cancellable.store(in: &subscriptions)
    }
}

// MARK: Global Bike Search queries

extension Client {
    func queryGlobal(context: ModelContext) {
        Logger.api.debug("\(#function) enter")

        /* https://bikeindex.org:443/api/v3/search?page=1&per_page=25&location=IP&distance=10&stolenness=stolen&access_token=Lo-dGPjIpS-6YiVT0zT8ezB6IYv1zqIiQ85iAEeeWRM */

        var url = configuration.host.appendingPathComponent("api/v3/search")
        url.append(queryItems: [
            URLQueryItem(name: "per_page", value: String(25)),
            URLQueryItem(name: "page", value: String(1)),
            URLQueryItem(name: "location", value: "IP"),
            URLQueryItem(name: "distance", value: "10"),
            URLQueryItem(name: "stolenness", value: "stolen"),
            URLQueryItem(name: Constants.accessToken, value: auth?.accessToken),
        ])

        let cancellable = session
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ResponseBikes.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { Logger.api.debug("\(#function) Received completion: \(String(describing: $0)).") },
                  receiveValue: { response in
                Logger.api.debug("\(#function) Received response: \(String(describing: response)),")
                response.bikes.forEach {
                    context.insert($0)
                }
            })

        cancellable.store(in: &subscriptions)

    }
}
