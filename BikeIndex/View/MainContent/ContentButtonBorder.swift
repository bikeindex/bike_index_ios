//
//  ContentButtonBorder.swift
//  BikeIndex
//
//  Created by Jack on 1/22/26.
//

import SwiftUI

struct ContentButtonBorder: View {
    var frameColors: [FrameColor]

    var body: some View {
        borderGradient
            .frame(
                minWidth: 100,
                maxWidth: .infinity,
                minHeight: 100,
                maxHeight: .infinity
            )
            .cornerRadius(24)
            .overlay {
                Image(systemName: "bicycle")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .tint(.secondary)
                    .foregroundStyle(.primary)
                    .shadow(color: .accent, radius: 1)
            }
    }

    var borderGradient: LinearGradient {
        LinearGradient(colors: frameColors.compactMap(\.color), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    ScrollView {
        ProportionalLazyVGrid {
            ContentButtonBorder(frameColors: [.bareMetal, .blue, .red])
            ContentButtonBorder(frameColors: [.red, .orange, .yellow])
            ContentButtonBorder(frameColors: [.covered, .white, .black])
            ContentButtonBorder(frameColors: [.red, .pink, .white])
            ContentButtonBorder(frameColors: [.green, .blue, .purple])
        }
    }
}
