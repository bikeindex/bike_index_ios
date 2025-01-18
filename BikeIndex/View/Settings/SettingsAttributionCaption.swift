//
//  SettingsAttributionCaption.swift
//  BikeIndex
//
//  Created by Jack on 1/18/25.
//

import SwiftUI

/// Display attirbution captions about the app, usually in a SettingsPage footer
struct SettingsAttributionCaption: View {
    let appVersion = AppVersionInfo()

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Made with 💝 in Pittsburgh, PA")
                if let marketingVersion = appVersion.marketingVersion,
                   let buildNumber = appVersion.buildNumber {
                    Text("Version \(marketingVersion) (\(buildNumber))")
                        .font(.caption)
                }
            }
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    SettingsAttributionCaption()
}
