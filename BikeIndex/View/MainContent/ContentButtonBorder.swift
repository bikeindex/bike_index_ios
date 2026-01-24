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
        Image(systemName: "bicycle")
            .resizable()
            .scaledToFit()
            .padding()
            .frame(
                minWidth: 100,
                maxWidth: .infinity,
                minHeight: 100,
                maxHeight: .infinity
            )
//            .clipShape(RoundedRectangle(cornerRadius: 24))

            .tint(.secondary)
            .foregroundStyle(.primary)
            .shadow(color: .accent, radius: 4)

//            .buttonBorderShape(.roundedRectangle)
//            .clipShape(RoundedRectangle(cornerRadius: 24))

//            .border(borderGradient,
//                    width: 10)

            .clipShape(RoundedRectangle(cornerRadius: 24))

            .background {
                borderGradient
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
