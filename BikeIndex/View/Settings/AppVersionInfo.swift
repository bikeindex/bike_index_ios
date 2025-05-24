//
//  AppVersionInfo.swift
//  BikeIndex
//
//  Created by Jack on 1/18/25.
//

import SwiftUI

struct AppVersionInfo {
    var marketingVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    var referralSource: String {
        marketingVersion.map { "app-ios-\($0)" } ?? "app-ios"
    }
}
