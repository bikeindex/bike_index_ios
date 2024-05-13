//
//  WelcomeView.swift
//  BikeIndex
//
//  Created by Jack on 1/1/24.
//

import SwiftUI

/// Pair with ``AuthView`` for a complete login experience
struct WelcomeView: View {
    @Environment(Client.self) var client
    @Environment(\.colorScheme) var colorScheme

    @State var iconsModel = AlternateIconsModel()

    var body: some View {
        VStack {
            Spacer()

            HStack {
                if let uiImage = UIImage(named: iconsModel.selectedAppIcon.rawValue) {
                    Image(uiImage: uiImage)
                        .appIcon(scale: .large)
                        .frame(maxWidth: .infinity,
                               maxHeight: 200)
                } else {
                    Image(systemName: iconsModel.absentIcon)
                        .appIcon(scale: .large)
                        .frame(maxWidth: .infinity,
                               maxHeight: 200)
                }
                Spacer()
            }

            Text("The world's largest and most effective bicycle registry and stolen bike recovery platform.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            Spacer()
        }
        .toolbarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(colorScheme == .light ? .black : .blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
            .environment(try! Client())
            .navigationTitle("Welcome to Bike Index")
    }
}
