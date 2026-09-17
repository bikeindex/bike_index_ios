//
//  Client.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import HoneybadgerSwift
import KeychainSwift
import OSLog
import StoreKit
import URLEncodedForm
import WebKit

/// Provide a subset of ``ClientConfiguration`` to control access.
struct HostProvider: Sendable {
    /// Must be in format: `https://domain.tld`, most often `https://bikeindex.org`
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
    /// Inject the keychain dependency as a variable, used by tests to stub.
    private var keychain: KeychainSwift

    /// The in-flight task that is attempting to restore a session from a persisted (possibly
    /// expired) keychain token. Non-nil while the token refresh is in flight.
    private var sessionRestorationTask: Task<Void, Never>?

    /// The in-flight warm-refresh task. Non-nil while a token refresh is in progress.
    private var refreshTask: Task<Void, Never>?

    /// True while a launch-time token refresh is in flight. Derived from the task reference so
    /// it is always in sync with the actual work.
    var isRestoringSession: Bool {
        sessionRestorationTask != nil
    }

    // MARK: Refresh Properties
    var refreshTimer: Timer?
    var refreshRunLoop: RunLoop

    init(
        keychain: KeychainSwift = KeychainSwift(),
        refreshRunLoop: RunLoop = RunLoop.main,
        restoreSession: Bool = true
    ) throws {
        self.backgroundSessionDelegate = BackgroundSessionDelegate()
        self.backgroundSession = URLSession(
            configuration: .background(withIdentifier: "BackgroundSession"),
            delegate: backgroundSessionDelegate, delegateQueue: nil)
        self.keychain = keychain
        self.refreshRunLoop = refreshRunLoop
        let configuration = try ClientConfiguration.bundledConfig()
        self.configuration = configuration
        if restoreSession {
            loadLastToken()
        }

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
    /// If the stored token is still valid, the session is restored synchronously.
    /// If the stored token is expired, a background token refresh is attempted immediately so the
    /// user is signed in automatically on launch. If the refresh token itself is rejected, the
    /// persisted session is wiped and the user will see the welcome screen.
    private func loadLastToken() {
        guard let lastKnownToken = self.keychain.get(Keychain.oauthToken),
            let rawData = lastKnownToken.data(using: .utf8)
        else {
            Logger.api.debug("\(#function) Could not find valid oauth token in keychain")
            return
        }

        do {
            let lastKnownAuth = try JSONDecoder().decode(OAuthToken.self, from: rawData)
            guard lastKnownAuth.isValid else {
                Logger.api.info(
                    "Client.\(#function) found existing token, but it is expired; attempting refresh"
                )
                sessionRestorationTask = Task { [weak self] in
                    // Re-check in case a concurrent sign-in already updated the token
                    guard let self, !(self.auth?.isValid ?? false) else {
                        self?.sessionRestorationTask = nil
                        return
                    }
                    let result = await self.renewToken(refreshToken: lastKnownAuth.refreshToken)
                    self.sessionRestorationTask = nil
                    switch result {
                    case .success:
                        Logger.api.info(
                            "Client.\(#function) restored session from keychain token refresh")
                    case .failure(let failure):
                        Logger.api.error(
                            "Client.\(#function) failed to restore session, \(failure, privacy: .public)"
                        )
                        self.invalidateAuth()
                    }
                }
                return
            }

            auth = lastKnownAuth
            accessToken = lastKnownAuth.accessToken

            setupRefreshTimer()

            Logger.api.debug(
                "Client.\(#function) found existing valid token \(String(describing: lastKnownAuth), privacy: .private)"
            )
        } catch {
            Honeybadger.notify(error: error)
            Logger.api.debug("Failed to find existing auth")
        }
    }

    // MARK: Logout
    /// Allow users to log out
    func destroySession() async {
        // Clear web state
        // NOTE: We could parse this for a 302 redirect to /goodbye but that seems unnecessary
        let logoutResult = await get(OAuth.logout)
        switch logoutResult {
        case .success(let success):
            Logger.api.info(
                "\(#function) Logged out successfully, \(String(describing: success), privacy: .public)"
            )
        case .failure(let failure):
            // Don't report to Honeybadger, mimeType==text/html response is not parsed
            Logger.api.info("\(#function) Failed to call logout, \(failure, privacy: .public)")
        }

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

        invalidateAuth()
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

        let fullToken: Result<OAuthToken, Error> = await post(OAuth.token(queryItems: tokenQuery))
        switch fullToken {
        case .success(let fullTokenAuth):
            self.auth = fullTokenAuth
            self.accessToken = fullTokenAuth.accessToken
            self.setupRefreshTimer()
            do {
                let data = try JSONEncoder().encode(fullTokenAuth)
                self.keychain.set(data, forKey: Keychain.oauthToken)
            } catch {
                Honeybadger.notify(error: error)
                Logger.client.error(
                    "Failed to persist /oauth/token to keychain after fetching successfully, continuing"
                )
            }
            Logger.client.info("OAuth token received successfully")
        case .failure(let failure):
            Logger.client.error("Failed to fetch /oauth/token \(failure)")
            return false
        }

        return true
    }

    func invalidateAuth() {
        Logger.client.warning("Auth invalidated, clearing session")
        Honeybadger.reset()
        self.refreshTask?.cancel()
        self.refreshTask = nil
        self.sessionRestorationTask?.cancel()
        self.sessionRestorationTask = nil
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        self.auth = nil
        self.accessToken = nil
        self.keychain.delete(Keychain.oauthToken)
    }

    /// Inform any `@State` watchers if the authentication is valid or has become void.
    var authenticated: Bool {
        if let auth {
            auth.isValid
        } else {
            false
        }
    }

    /// Renew the session token 3 minutes before expiration
    /// Expiration local var will be a negative time interval
    func setupRefreshTimer() {
        guard let auth else {
            return
        }
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        let expiration = (auth.expiration - 15).timeIntervalSinceNow
        let bufferedExpirationInterval = max(expiration, 15)
        Logger.client.debug(
            "\(#function), refresh timer will run in \(bufferedExpirationInterval) interval. Original expiration was: \(expiration)"
        )
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
            Logger.client.warning("No active refresh timer available, skipping force refresh")
            return
        }
        refreshToken(timer: refreshTimer)
    }

    @objc func refreshToken(timer: Timer) {
        guard let tokenInfo = timer.userInfo as? [String: OAuthToken],
            let tokenPayload = tokenInfo["token"]
        else {
            Logger.client.error("refreshToken(timer:) timer userInfo is missing 'token'")
            return
        }

        // Skip if a refresh is already in flight to prevent racing on a single-use refresh token.
        guard refreshTask == nil else {
            Logger.client.warning("refreshToken(timer:) skipped, refresh already in flight")
            return
        }

        refreshTask = Task { [weak self] in
            guard let self else { return }
            let renewedTokenRequest: Result<OAuthToken, Error> = await self.renewToken(
                refreshToken: tokenPayload.refreshToken)
            self.refreshTask = nil
            switch renewedTokenRequest {
            case .success:
                break
            case .failure(let failure):
                Logger.client.error("Failed to fetch /oauth/token \(failure)")
                self.invalidateAuth()
                Honeybadger.reset()
            }
        }
    }

    /// Exchange a refresh token for a new OAuth token, update in-memory state, and persist it.
    /// - Parameter refreshToken: The refresh token value to send to `OAuth.refresh`.
    /// - Returns: Success if the new token was applied and persisted. Failure if the server
    ///   rejected the refresh token (session is dead) or on any other transport error.
    @discardableResult
    private func renewToken(refreshToken: Token) async -> Result<OAuthToken, Error> {
        let tokenQuery = [
            ("client_id", configuration.clientId),
            ("client_secret", configuration.secret),
            ("refresh_token", refreshToken),
            ("grant_type", "refresh_token"),
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }

        let renewedTokenRequest: Result<OAuthToken, Error> = await post(
            OAuth.refresh(queryItems: tokenQuery))
        switch renewedTokenRequest {
        case .success(let refreshedToken):
            self.auth = refreshedToken
            self.accessToken = refreshedToken.accessToken
            self.setupRefreshTimer()
            do {
                let data = try JSONEncoder().encode(refreshedToken)
                self.keychain.set(data, forKey: Keychain.oauthToken)
            } catch {
                Honeybadger.notify(error: error)
                Logger.client.error(
                    "Failed to persist /oauth/token to keychain after fetching successfully, continuing"
                )
            }
            Logger.client.info("Refreshed oauth token to keychain")
            return .success(refreshedToken)
        case .failure(let failure):
            Logger.client.error("Failed to fetch /oauth/token \(failure)")
            return .failure(failure)
        }
    }
}

#if DEBUG
/// #Preview-only variation of Client to force isRestoringSession=true purely
/// for SwiftUI preview design. Starts a never-completing task so the computed
/// property reports `true`.
extension Client {
    func alwaysRestoringSession() -> Self {
        sessionRestorationTask = Task { [weak self] in
            // Block indefinitely; this task is only alive in a #Preview context.
            while self != nil {
                try? await Task.sleep(for: .seconds(3600))
            }
        }
        return self
    }
}
#endif
