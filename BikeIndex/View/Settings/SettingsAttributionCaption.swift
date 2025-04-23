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
                Text("2025 © Bike Index")
                Text("A 501(c)(3) nonprofit - EIN 81-4296194")
                Spacer()
                Text("[Candid.org profile](https://app.candid.org/profile/9575027)")
                Spacer()
                Text("Made with 💝 in Pittsburgh, PA")
                if let marketingVersion = appVersion.marketingVersion,
                    let buildNumber = appVersion.buildNumber
                {
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
