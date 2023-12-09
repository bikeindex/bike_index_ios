//
//  ClientConfiguration.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import OSLog

/// Represents API and Networking configuration. Reads values from the BikeIndex.xccconfig file.
/// Any project instance must copy BikeIndex-template.xcconfig into BikeIndex.xcconfig and provide values.
struct ClientConfiguration {

    // MARK: Networking Essentials
    /// Primary host for the base of all bikeindex URLs
    let host: URL
    /// Primary port for the base of all bikeindex URLs
    let port: UInt16

    // MARK: OAuth
    /// Known as "Application ID" from the https://bikeindex.org/oauth/applications detail page
    let clientId: String
    /// Known as "Secret" from the https://bikeindex.org/oauth/applications detail page
    let secret: String
    /// Known as "Callback URLs" from the https://bikeindex.org/oauth/applications detail page
    /// Must have a corresponding entry in Info.plist > CFBundleURLTypes
    let redirectUri: String

    /// Array of scopes that will be requested when authorizing users
    /// Not configurable in the xcconfig
    /// Defaults to all
    let oauthScopes: [Scope] = Scope.allCases

    /// Load the API network service information and OAuth configuration from BikeIndex-\*.xcconfig project files.
    /// Please see BikeIndex-template.xcconfig for instructions to provide these values.
    static func bundledConfig() throws -> Self {
        guard let info = Bundle.main.infoDictionary,
              let clientId = info["API_CLIENT_ID"] as? String,
              let secret = info["API_SECRET"] as? String,
              let hostString = (info["API_HOST"] as? String)?
            .replacing("\\/\\/", with: "//"),
              var host = URL(string: hostString),
              let portString = info["API_PORT"] as? String,
              let port = UInt16(portString),
              let redirectUri = (info["API_REDIRECT_URI"] as? String)?
            .replacing("\\/\\/", with: "//")
        else {
            throw ClientConfigurationError.failedToLoadBundle
        }

        if port != 443 {
            if let hostWithPort = URL(string: hostString + ":\(port)") {
                host = hostWithPort
                Logger.api.debug("Loaded configuration at host \(String(describing: host))")
            } else {
                throw ClientConfigurationError.failedToLoadBundleWithPort
            }
        }

        return ClientConfiguration(host: host,
                                   port: port,
                                   clientId: clientId,
                                   secret: secret,
                                   redirectUri: redirectUri)
    }

    enum ClientConfigurationError: Error {
        case failedToLoadBundle
        case failedToLoadBundleWithPort
    }
}
