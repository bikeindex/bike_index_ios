//
//  Organization.swift
//  BikeIndex
//
//  Created by Jack on 5/13/26.
//

import Foundation
import SwiftData

/// An organization the authenticated user belongs to, as served by `GET /api/v3/me`.
///
/// One ``Organization`` is stored per membership. The same organization can appear more
/// than once (once per user role) because the membership state (`userIsOrganizationAdmin`,
/// `accessToken`, `menu`) is per-relationship, not per-organization.
@Model final class Organization {
    /// The organization's numeric ID on the server.
    fileprivate(set) var identifier: Int
    fileprivate(set) var name: String
    fileprivate(set) var shortName: String
    fileprivate(set) var slug: String
    fileprivate(set) var logo: URL?
    /// The access token scoped to this organization's membership.
    fileprivate(set) var accessToken: String
    /// Whether the user is an admin of this organization.
    fileprivate(set) var userIsOrganizationAdmin: Bool

    /// The organization menu rendered by the web UI, served per-user and per-organization.
    fileprivate(set) var menu: [MenuItem]

    init(
        identifier: Int,
        name: String,
        shortName: String,
        slug: String,
        logo: URL? = nil,
        accessToken: String,
        userIsOrganizationAdmin: Bool,
        menu: [MenuItem]
    ) {
        self.identifier = identifier
        self.name = name
        self.shortName = shortName
        self.slug = slug
        self.logo = logo
        self.accessToken = accessToken
        self.userIsOrganizationAdmin = userIsOrganizationAdmin
        self.menu = menu
    }
}

/// One row of the per-user, per-organization menu served in `GET /api/v3/me` memberships.
///
/// Mirrors the shape the Rails `ComponentStructs::Shapes` constructors produce:
/// - `.divider`: a bare separator with no other attributes
/// - `.group`: a collapsible section (`key`, `label`, `icon`) owning `children`
/// - `.link`: a navigation row (`label`, `path`, optional `icon`, `matchPaths`, `matchParams`)
/// - `.disabled`: a greyed-out row with no navigation (`label`)
///
/// The menu is display-only data re-fetched from `GET /me` on each session, so the
/// (possibly nested) rows are stored as an ordered JSON payload rather than a self-referencing
/// SwiftData relationship.
@Model final class MenuItem {
    fileprivate(set) var type: String
    /// `.link` and `.disabled` rows carry a label; `.group` rows carry the section title.
    fileprivate(set) var label: String?
    /// The group's collapse key (`.group` rows only).
    fileprivate(set) var key: String?
    /// The icon name (`.link`/`.group` rows).
    fileprivate(set) var icon: String?
    /// The path the row navigates to (`.link` rows).
    fileprivate(set) var path: String?
    /// Paths this row is "active" on (`.link` rows).
    fileprivate(set) var matchPaths: [String]
    /// Query params this row is "active" on (`.link` rows).
    /// A `nil` value means "match only when the param is absent" (e.g. `parking_notification`).
    fileprivate(set) var matchParams: [String: MatchParam]
    /// The rows nested inside a `.group`, as an ordered JSON payload.
    fileprivate(set) var childrenJSON: Data?

    init(
        type: String,
        label: String? = nil,
        key: String? = nil,
        icon: String? = nil,
        path: String? = nil,
        matchPaths: [String] = [],
        matchParams: [String: MatchParam] = [:],
        childrenJSON: Data? = nil
    ) {
        self.type = type
        self.label = label
        self.key = key
        self.icon = icon
        self.path = path
        self.matchPaths = matchPaths
        self.matchParams = matchParams
        self.childrenJSON = childrenJSON
    }

    /// The rows nested inside this item (`.group` rows only), decoded on demand.
    var children: [MenuItemJSON] {
        guard let childrenJSON,
              let decoded = try? JSONDecoder().decode([MenuItemJSON].self, from: childrenJSON)
        else { return [] }
        return decoded
    }
}

/// A decoded menu row (the shape of the JSON served by the API and stored in
/// ``MenuItem/childrenJSON``). Distinct from the ``MenuItem`` model so nested rows
/// don't form a self-referencing SwiftData relationship.
struct MenuItemJSON: Codable {
    let type: String
    let label: String?
    let key: String?
    let icon: String?
    let path: String?
    /// Paths this row is "active" on (`.link` rows only; absent on other rows).
    let matchPaths: MatchPaths?
    /// Query params this row is "active" on (`.link` rows only; absent on other rows).
    let matchParams: [String: MatchParam]
    /// Nested rows (`.group` rows only; absent on other rows).
    let children: [MenuItemJSON]?

    enum CodingKeys: String, CodingKey {
        case type, label, key, icon, path, children
        case matchPaths = "match_paths"
        case matchParams = "match_params"

        init(_ rawName: String) {
            self = Self(rawValue: rawName) ?? .type
        }
    }

    init(
        type: String,
        label: String? = nil,
        key: String? = nil,
        icon: String? = nil,
        path: String? = nil,
        matchPaths: [String]? = nil,
        matchParams: [String: MatchParam] = [:],
        children: [MenuItemJSON]? = nil
    ) {
        self.type = type
        self.label = label
        self.key = key
        self.icon = icon
        self.path = path
        self.matchPaths = matchPaths.map(MatchPaths.init)
        self.matchParams = matchParams
        self.children = children
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        path = try container.decodeIfPresent(String.self, forKey: .path)

        // `match_paths`/`match_params`/`children` only appear on the row types that carry
        // them, so they're looked up by raw name rather than decoded as optional properties
        // (which would still throw `keyNotFound` when absent).
        matchPaths = try container.decodeIfPresent(MatchPaths.self, forKey: CodingKeys("match_paths"))
        matchParams = try container.decodeIfPresent(
            [String: MatchParam].self, forKey: CodingKeys("match_params")) ?? [:]
        children = try container.decodeIfPresent([MenuItemJSON].self, forKey: CodingKeys("children"))
    }
}

/// A path the row is "active" on (`.link` rows). The server serves this polymorphically:
/// a single glob string (e.g. `/o/brakebills/stickers/**`) or an array of paths
/// (e.g. `["/o/brakebills/dashboard/**", "/o/brakebills"]`). Decoded into a normalized
/// array of paths.
struct MatchPaths: Codable {
    let paths: [String]

    init(_ paths: [String]) {
        self.paths = paths
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let path = try? container.decode(String.self) {
            paths = [path]
        } else {
            paths = try container.decode([String].self)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(paths)
    }
}

/// A query param value the row is "active" on (`.link` rows). The server serves these
/// polymorphically:
/// - `null` — match only when the param is absent (e.g. `parking_notification: null`)
/// - `true` / `false` — match when the param is exactly that boolean (e.g. `parking_notification: true`)
/// - a string — match when the param is exactly that string
struct MatchParam: Codable, Equatable {
    let value: String?
    /// Whether the server served this as a boolean (`true`/`false`) rather than a string or null.
    let isBoolean: Bool

    init(value: String?, isBoolean: Bool = false) {
        self.value = value
        self.isBoolean = isBoolean
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            isBoolean = false
        } else if let bool = try? container.decode(Bool.self) {
            value = bool ? "true" : "false"
            isBoolean = true
        } else {
            value = try container.decode(String.self)
            isBoolean = false
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value == nil {
            try container.encodeNil()
        } else if isBoolean {
            try container.encode(value == "true")
        } else {
            try container.encode(value)
        }
    }
}
