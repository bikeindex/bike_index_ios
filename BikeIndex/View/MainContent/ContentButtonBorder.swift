//
//  ContentButtonBorder.swift
//  BikeIndex
//
//  Created by Jack on 1/22/26.
//

import SwiftUI

@available(*, deprecated, message: "TODO: Rename, this is the wrong name.")
// ✅ DONE: Use vertical stripes for simplicity and clarity
// TODO: Add public bike image to the Preview and check with images too
// TODO: Rely on https://bikeindex.org/api/v3/selections/colors
struct ContentButtonBorder: View {
    var frameColors: [FrameColor]

    var body: some View {
        ZStack {
            // Textured FrameColor background IF applicable
            HStack(spacing: 0) {
                ForEach(.constant(frameColors), id: \.id) { frame in
                    switch frame.wrappedValue {
                    case .bareMetal:
                        Rectangle().overlay {
                            Chip.bareMetalAngularGradient
                        }
                    case .covered:
                        // Covered
                        if #available(iOS 18.0, *) {
                            Rectangle().overlay {
                                Chip.rainbow18
                            }
                        } else {
                            Chip.rainbow17
                        }
                    default:
                        EmptyView()
                    }
                }
                
            }
            .aspectRatio(1.0, contentMode: .fit)
            .clipped()

            // Foreground stripes of solid frame colors, with cutouts for textured background
            GeometryReader { geo in
                HStack(spacing: 0) {
                    let count = CGFloat(frameColors.count)
                    ForEach(.constant(frameColors), id: \.id) { frame in
                        switch frame.wrappedValue {
                        case .bareMetal:
                            Spacer()
                                .frame(width: geo.size.width / count)
                        case .covered:
                            Spacer()
                                .frame(width: geo.size.width / count)
                        case (let value):
                            // Color with value
                            if let color = value.color {
                                // TODO: Fix color.gradient here
                                LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing)
                                    .zIndex(100)
                                    .frame(width: geo.size.width / count)
                            } else {
                                Text("Inconsident FrameColor usage")
                            }
                        }
                    }
                }
            }
            .aspectRatio(1.0, contentMode: .fit)

        }
        .frame(
            minWidth: 100,
            minHeight: 100
        )
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(24)
        .overlay {
            Image(systemName: "bicycle")
                .resizable()
                .scaledToFit()
                .padding()
                .tint(.secondary)
                .foregroundStyle(.primary)
                .shadow(color: Color(uiColor: .systemBackground), radius: 5)
        }
    }
}

#Preview {
    ScrollView {
        ProportionalLazyVGrid {
            ContentButtonBorder(frameColors: [.blue, .red, .bareMetal])
            ContentButtonBorder(frameColors: [.red, .orange, .yellow])
            ContentButtonBorder(frameColors: [.white, .black, .covered])
            ContentButtonBorder(frameColors: [.bareMetal, .white, .covered])
            if #available(iOS 18, *) {
                Chip.rainbow18
            } else {
                Chip.rainbow17
            }
            ContentButtonBorder(frameColors: [.green, .blue, .purple])
            Chip.bareMetalAngularGradient
                .frame(
                    minWidth: 100,
                    minHeight: 100,
                )
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}
