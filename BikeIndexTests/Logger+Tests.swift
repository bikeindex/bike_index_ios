//
//  Logger+Tests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/26/23.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let tests = Logger(subsystem: subsystem, category: "tests")
}
