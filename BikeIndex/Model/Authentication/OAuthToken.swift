//
//  OAuthToken.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

typealias Token = String

struct OAuthToken: Codable, Equatable {
    // MARK: JSON properties
    let accessToken: Token
    let tokenType: String
    let expiresIn: TimeInterval
    let refreshToken: Token
    let scope: [Scope]
    let createdAt: Date

    // MARK: Synthesized property
    var expiration: Date {
        createdAt.addingTimeInterval(expiresIn)
    }
}

extension OAuthToken {
    enum CodingKeys: String, CodingKey {
        // https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy/convertfromsnakecase
        // Alternatively use convertFromSnakeCase decoding strategy but that would incur a performance cost.
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(Token.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
        self.refreshToken = try container.decode(Token.self, forKey: .refreshToken)

        let createdInt = try container.decode(Int.self, forKey: .createdAt)
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(createdInt))

        let scopeString = try container.decode(String.self, forKey: .scope)
        self.scope = scopeString.components(separatedBy: " ").compactMap { Scope(rawValue: $0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(tokenType, forKey: .tokenType)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)

        let scopeString = scope.reduce(into: "") { partial, value in
            partial += "\(scope) "
        }
        try container.encode(scopeString, forKey: .scope)
    }
}

extension OAuthToken {
    var isValid: Bool {
        Date() < expiration
    }
}

enum Scope: String, CaseIterable, Identifiable {
    var id: Self { self }

    case readUser = "read_user"
    case writeUser = "write_user"

    case readBikes = "read_bikes"
    case writeBikes = "write_bikes"
}

extension [Scope] {
    /// Transform this array of `Scope` to be used in an API request for the sign-in page.
    var queryItem: String {
        self.map { $0.rawValue }.joined(separator: "+")
    }
}
