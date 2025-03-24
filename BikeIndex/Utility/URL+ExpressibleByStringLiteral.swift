//
//  URL+ExpressibleByStringLiteral.swift
//  BikeIndex
//
//  Created by Jack on 3/16/25.
//

import Foundation

/// Inspired by SwiftLee Weekly - Issue 260
extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension URL: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}
