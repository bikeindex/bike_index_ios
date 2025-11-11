//
//  Client.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import KeychainSwift
import OSLog
import StoreKit
import URLEncodedForm
import WebKit

/// Provide a subset of ``ClientConfiguration`` to control access.
struct HostProvider: Sendable {
    let host: URL
}

/// Convenience wrapper to shuttle query items from an array of string-tuples into actual `URLQueryItem` objects.
typealias QueryItemTuple = (name: String, value: String)

/// Stateful API client for interacting with bikeindex.org
/// Controls networking state and loads app configuration from the bundle.
/// Performs ``get(_:)`` and ``post(_:)`` requests.
@MainActor
@Observable class Client {
    // MARK: Configuration and Helpers
    internal let session = URLSession(configuration: .default)
    internal let backgroundSessionDelegate: BackgroundSessionDelegate
    internal let backgroundSession: URLSession

    /// App configuration loaded from .xcconfig files to determine the network environment
    private(set) var configuration: ClientConfiguration
    /// Convenience access to host provider for Base URL validation and construction
    var hostProvider: HostProvider {
        configuration.hostProvider
    }
    /// Stateful shared webview configuration to manage cookie storage for logout and javascript/css injection scripts.
    private(set) var webConfiguration = WKWebViewConfiguration()

    // MARK: Authorization State

    /// Full OAuth token response.
    internal var auth: OAuthToken?
    /// Access token is provided by the OAuth flow to the application from `ASWebAuthenticationSession`.
    /// The access token may be required in requests and it may be used to retrieve the full OAuth token (see ``auth``).
    internal var accessToken: Token?
    private var keychain = KeychainSwift()

    // MARK: Refresh Properties
    var refreshTimer: Timer?
    var refreshRunLoop: RunLoop

    // MARK: Deeplink State
    /// Deeplinks can be opened from stickers at any time.
    /// Client will keep the authoritative reference to a deeplink manager.
    var deeplinkManager: DeeplinkManager

    init(
        keychain: KeychainSwift = KeychainSwift(),
        refreshRunLoop: RunLoop = RunLoop.main
    ) throws {
        self.backgroundSessionDelegate = BackgroundSessionDelegate()
        self.backgroundSession = URLSession(configuration: .background(withIdentifier: "BackgroundSession"), delegate: backgroundSessionDelegate, delegateQueue: nil)
        self.keychain = keychain
        self.refreshRunLoop = refreshRunLoop
        let configuration = try ClientConfiguration.bundledConfig()
        self.configuration = configuration
        self.deeplinkManager = DeeplinkManager(host: configuration.hostProvider)
        loadLastToken()

        // Configure webView manipulation scripts
        Task {
            webConfiguration.userContentController.addUserScript(WebScripts.removeFrame)

            if let countryCode = await Storefront.current?.countryCode, countryCode != "USA" {
                webConfiguration.userContentController
                    .addUserScript(WebScripts.hideMembership)
                Logger.donate.debug("App is outside the US app store")
            } else {
                Logger.donate.debug("App is inside the US app store")
            }
        }
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
            let rawData = lastKnownToken.data(using: .utf8)
        {
            do {
                let lastKnownAuth = try JSONDecoder().decode(OAuthToken.self, from: rawData)

                auth = lastKnownAuth
                accessToken = lastKnownAuth.accessToken

                setupRefreshTimer()

                Logger.api.debug(
                    "Client.\(#function) found existing valid token \(String(describing: lastKnownAuth), privacy: .private)"
                )
            } catch {
                Logger.api.debug("Failed to find existing auth")
            }
        } else {
            Logger.api.debug("\(#function) Could not find valid oauth token in keychain")
        }
    }

    /// Allow users to log out
    func destroySession() async {
        // Clear web state
        // NOTE: We could parse this for a 302 redirect to /goodbye but that seems unnecessary
        _ = await get(OAuth.logout)

        let allCookies = await webConfiguration.websiteDataStore.httpCookieStore.allCookies()
        var authCookie: HTTPCookie?
        for cookie in allCookies {
            if cookie.name == "auth" {
                authCookie = cookie
            }
            Logger.client.info("Evaluated cookie named \(cookie.name) during sign-out")
        }
        Logger.client.warning("Found \(allCookies.count) cookies")
        if let authCookie {
            await webConfiguration.websiteDataStore.httpCookieStore.deleteCookie(authCookie)
        } else {
            Logger.client.warning("Failed to find and destroy auth cookie")
        }

        // Clear app state
        KeychainSwift().delete(Keychain.oauthToken)
        accessToken = nil
        auth = nil
    }

    var userCanRegisterBikes: Bool {
        configuration.oauthScopes.contains(Scope.writeBikes)
    }

    // MARK: - Authentication Operations

    /// Stateful function to receive results of an authentication result.
    /// - Parameter authCallback: The "redirect URI" received from the OAuth provider. This should contain relevant
    /// query parameters to continue with a valid session. This *must* contain a `code` query paramter which will be
    /// forwarded to the ``OAuth.token`` endpoint.
    /// - Returns: True if processing proceeded normally. False if any errors occurred.
    @discardableResult func accept(authCallback: URL) async -> Bool {
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

        // Step 2: Perform the full token fetch now that we have a requisite access code.
        let tokenQuery = [
            ("client_id", configuration.clientId),
            ("client_secret", configuration.secret),
            ("code", newToken),
            ("grant_type", "authorization_code"),
            ("redirect_uri", configuration.redirectUri),
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }

        let fullToken = await get(OAuth.token(queryItems: tokenQuery))
        switch fullToken {
        case .success(let success):
            guard let fullTokenAuth = success as? OAuthToken else {
                return false
            }
            self.auth = fullTokenAuth
            self.accessToken = fullTokenAuth.accessToken
            self.setupRefreshTimer()
            do {
                let data = try JSONEncoder().encode(fullTokenAuth)
                self.keychain.set(data, forKey: Keychain.oauthToken)
            } catch {
                Logger.client.error(
                    "Failed to persist /oauth/token to keychain after fetching successfully, continuing"
                )
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

    // Renew the session token 3 minutes before expiration
    func setupRefreshTimer() {
        guard let auth else {
            fatalError()
        }
        let bufferedExpirationInterval = (auth.expiration - 60 * 3).timeIntervalSinceNow
        let timer = Timer(
            timeInterval: bufferedExpirationInterval,
            target: self,
            selector: #selector(self.refreshToken(timer:)),
            userInfo: ["token": auth],
            repeats: false)
        refreshRunLoop.add(timer, forMode: .default)
        refreshTimer = timer
    }

    func forceRefreshToken() {
        guard let refreshTimer else {
            fatalError()
        }
        refreshToken(timer: refreshTimer)
    }

    @objc func refreshToken(timer: Timer) {
        let refreshToken = self.auth?.refreshToken ?? ""

        let tokenQuery = [
            ("client_id", configuration.clientId),
            ("refresh_token", refreshToken),
            ("grant_type", "refresh_token"),
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }

        Task {
            let renewedTokenRequest = await get(OAuth.refresh(queryItems: tokenQuery))
            switch renewedTokenRequest {
            case .success(let success):
                guard let refreshedToken = success as? OAuthToken else {
                    Logger.client.error("Failed to parse oauthtoken from fetch")
                    return
                }

                self.auth = refreshedToken
                self.accessToken = refreshedToken.accessToken
                self.setupRefreshTimer()
                do {
                    let data = try JSONEncoder().encode(refreshedToken)
                    self.keychain.set(data, forKey: Keychain.oauthToken)
                } catch {
                    Logger.client.error(
                        "Failed to persist /oauth/token to keychain after fetching successfully, continuing"
                    )
                }
                Logger.client.info("Refreshed oauth token to keychain")
            case .failure(let failure):
                Logger.client.error("Failed to fetch /oauth/token \(failure)")
            }
        }
    }
}
