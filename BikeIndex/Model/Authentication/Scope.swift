//
//  Scope.swift
//  BikeIndex
//
//  Created by Jack on 8/9/25.
//

import Foundation

enum Scope: String, CaseIterable, Identifiable {
    var id: Self { self }

    case readUser = "read_user"
    case writeUser = "write_user"

    case readBikes = "read_bikes"
    case writeBikes = "write_bikes"

    case readOrganizationMembership = "read_organization_membership"
}

extension [Scope] {
    /// Transform this array of `Scope` to be used in an API request for the sign-in page.
    var queryItem: String {
        self.map { $0.rawValue }.joined(separator: "+")
    }
}
