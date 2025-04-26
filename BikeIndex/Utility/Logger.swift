//
//  Logger.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog

/// OSLog implementation.
/// Note that Logger output will **not** be printed to SwiftUI Previews.
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let views = Logger(subsystem: subsystem, category: "views")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let api = Logger(subsystem: subsystem, category: "api")
    static let client = Logger(subsystem: subsystem, category: "client")
    static let model = Logger(subsystem: subsystem, category: "model")
    static let deeplinks = Logger(subsystem: subsystem, category: "deeplinks")
    static let webNavigation = Logger(subsystem: subsystem, category: "web-navigation")
}
