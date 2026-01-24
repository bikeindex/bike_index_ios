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
            .cornerRadius(24)
            .overlay {
                Image(systemName: "bicycle")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .tint(.secondary)
                    .foregroundStyle(.primary)
                    .shadow(color: .accent, radius: 1)

//                    .aspectRatio(1.0, contentMode: .fit)
//                    .background {
//                        RoundedRectangle(cornerRadius: 24)
//                    }
            }
            .frame(
                minWidth: 100,
                maxWidth: .infinity,
                minHeight: 100,
                maxHeight: .infinity
            )
            .aspectRatio(1.0, contentMode: .fit)
    }

    var borderGradient: AngularGradient {
//        LinearGradient(colors: frameColors.compactMap(\.color), startPoint: .topLeading, endPoint: .bottomTrailing)

        let colors = frameColors.compactMap(\.color)
        let count = colors.count
        let stops = colors.enumerated().map { (offset, color) in
            Gradient.Stop(color: color, location: CGFloat(offset / count))
        }
        return AngularGradient(stops: stops, center: .center, angle: .zero)
//        return AngularGradient(colors: colors, center: .center, startAngle: .zero, endAngle: .degrees(180))
    }
}

#Preview {
    ScrollView {
        ProportionalLazyVGrid {
            ContentButtonBorder(frameColors: [.bareMetal, .blue, .red])
            ContentButtonBorder(frameColors: [.red, .orange, .yellow])
            ContentButtonBorder(frameColors: [.covered, .white, .black])
            ContentButtonBorder(frameColors: [.white])
            ContentButtonBorder(frameColors: [.green, .blue, .purple])
        }
    }
}
