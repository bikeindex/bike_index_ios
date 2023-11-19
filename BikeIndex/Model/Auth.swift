//
//  Auth.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation

typealias Token = String

struct Auth: Codable, Equatable {
    let accessToken: Token
    let tokenType: String
    let expiresIn: TimeInterval
    let refreshToken: Token
    let scope: [Scope]
    let createdAt: Date

    let expiration: Date

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

        self.expiration = createdAt.addingTimeInterval(expiresIn)
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

extension Auth {
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

    case readOrganizationMembership = "read_organization_membership"
    case writeOrganizations = "write_organizations"
}

extension [Scope] {
    /// Transform `self` (an array of ``Scope``s) into a string delimited by plus signs
    /// that only occur between ``Scope`` values. (Do not add a trailing "+").
    var queryItem: String {
        self.enumerated().reduce(into: "") { partialResult, iteration in
            partialResult += iteration.element.rawValue
            partialResult += (iteration.offset + 1 < self.count) ? "+" : ""
        }
    }
}
