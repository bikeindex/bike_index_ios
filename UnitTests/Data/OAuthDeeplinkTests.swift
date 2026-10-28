//
//  OAuthDeeplinkTests.swift
//  UnitTests
//
//  Covers the *app-level* (onOpenURL) handling of OAuth authorization-code callbacks.
//
//  Background:
//  A Magic Link sign-in can complete outside the in-app WebView. The user taps the emailed link
//  in their mail app/browser, the web sign-in resumes the Doorkeeper OAuth flow, and the
//  resulting `redirect_uri` bounce (`bikeindex://?code=…`) is delivered to the app as a plain
//  deeplink through `onOpenURL` → `BikeIndexApp.handleUniversalLink`. Previously that path only
//  understood QR stickers, so the code callback was misreported as "Failed to handle deeplink"
//  and sign-in never completed. These tests pin down that such URLs are recognized as OAuth code
//  callbacks (and exchanged) rather than treated as stickers. The WebView-side interception is
//  covered separately in AuthInterceptorTests.
//

import Foundation
import Testing

@testable import BikeIndex

@MainActor
struct OAuthDeeplinkTests {

    /// The exact shape of the `bikeindex://?code=…` deeplink reported in production
    /// (Honeybadger: `Failed to handle deeplink Optional(bikeindex://?code=OhzsLqbM7nPNIrwvHDldJ5OZE4zOd7rrFsJR87fj10M)`).
    @Test(arguments: [
        // Reported in the wild (Magic Link sign-in)
        "bikeindex://?code=OhzsLqbM7nPNIrwvHDldJ5OZE4zOd7rrFsJR87fj10M",
        // A typical Doorkeeper authorization code
        "bikeindex://?code=edf1d0dec505adfd97e89ad2b76c2e71",
        // A code alongside other query parameters
        "bikeindex://?code=abc123&state=xyz",
    ])
    func recognizes_oauth_code_callback(rawInput: String) throws {
        let url = try #require(URL(string: rawInput))
        let client = try Client()

        #expect(client.isOAuthCodeCallback(url) == true)
    }

    /// URLs that are *not* OAuth code callbacks must not be recognized as one. Over-matching
    /// would swallow QR-sticker and sign-in-page deeplinks.
    @Test(arguments: [
        // QR sticker deeplink: bikeindex:// + an embedded https URL
        "bikeindex://https://bikeindex.org/bikes/scanned/BR0001",
        // The OAuth authorize page (https scheme, not the redirectUri scheme)
        "https://bikeindex.org/oauth/authorize?client_id=1&response_type=code&redirect_uri=bikeindex://&scope=read_user",
        // The sign-in page
        "https://bikeindex.org/session/new?return_to=%2Fbikes%2Fscanned%2FX",
        // redirectUri scheme but no query at all
        "bikeindex://",
        // redirectUri scheme with query params, but no `code`
        "bikeindex://?state=xyz",
        // No scheme
        "invalid_url",
    ])
    func does_not_treat_non_oauth_urls_as_code_callback(rawInput: String) throws {
        let url = try #require(URL(string: rawInput))
        let client = try Client()

        #expect(client.isOAuthCodeCallback(url) == false)
    }

    /// End-to-end: the exact deeplink that arrived in production must be recognized *and*
    /// successfully exchanged (via the mocked `accept`), i.e. the user signs in. This mirrors
    /// what `BikeIndexApp.handleUniversalLink` now does on the `onOpenURL` path: it recognizes
    /// the callback synchronously, then completes the token exchange asynchronously.
    @Test func production_magic_link_deeplink_signs_in_the_user() async throws {
        let code = "OhzsLqbM7nPNIrwvHDldJ5OZE4zOd7rrFsJR87fj10M"
        let url = try #require(URL(string: "bikeindex://?code=\(code)"))
        let client = try MockClient()

        // The synchronous recognition gate used by handleUniversalLink
        #expect(client.isOAuthCodeCallback(url) == true)

        // The async token exchange it then performs
        let completed = await client.accept(authCallback: url)
        #expect(completed == true)
        #expect(client.accessToken == code)
    }
}
