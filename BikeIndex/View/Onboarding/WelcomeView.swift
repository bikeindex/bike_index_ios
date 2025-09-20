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
    @Binding var displaySignIn: Bool

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Image(uiImage: iconsModel.selectedAppIcon.image)
                    .appIcon(scale: .large)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: 200)
                Spacer()
            }

            Text(
                "The world's largest and most effective bicycle registry and stolen bike recovery platform."
            )
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            Spacer()
            Button {
                displaySignIn = true
            } label: {
                Label(
                    "Sign in and get started",
                    systemImage: "person.crop.circle.dashed"
                )
                .accessibilityIdentifier("SignIn")
                .font(.title3)
                .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderedProminent)

        }
        .toolbarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(colorScheme == .light ? .black : .blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        WelcomeView(displaySignIn: .constant(false))
            .environment(try! Client())
            .navigationTitle("Welcome to Bike Index")
    }
}
