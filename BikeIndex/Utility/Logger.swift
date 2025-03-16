//
//  Logger.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let views = Logger(subsystem: subsystem, category: "views")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let api = Logger(subsystem: subsystem, category: "api")
    static let client = Logger(subsystem: subsystem, category: "client")
    static let model = Logger(subsystem: subsystem, category: "model")
}
