//
//  DisclosureButtonStyle.swift
//  BikeIndex
//
//  Created by Jack on 12/27/24.
//

import SwiftUI

/// Add a custom disclosure button to SettingsView buttons.
/// Replaces the NavigationLink built-in disclosure indicator.
struct DisclosureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundStyle(Color.accentColor)
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundColor(
                    Color(
                        hue: 0.5,
                        saturation: 0,
                        brightness: 0.75
                    )
                )
        }
    }
}

#Preview("DisclosureButton") {
    Form {
        Button("Show") {}
            .buttonStyle(DisclosureButtonStyle())
    }
}
