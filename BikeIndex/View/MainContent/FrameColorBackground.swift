//
//  FrameColorBackground.swift
//  BikeIndex
//
//  Created by Jack on 1/22/26.
//

import SwiftUI

// TODO: Rely on https://bikeindex.org/api/v3/selections/colors
struct FrameColorBackground: View {
    var frameColors: [FrameColor]

    var body: some View {
        ZStack {
            GeometryReader { geo in
                // Textured FrameColor background IF applicable
                ZStack {
                    let totalCount = frameColors.count
                    ForEach(Array(frameColors.enumerated()), id: \.element.id) { (offset, frame) in
                        switch frame {
                        case .bareMetal:
                            Chip.bareMetalAngularGradient
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(ColumnRectangle(column: offset, totalCount: totalCount))
                        case .covered:
                            // Covered
                            if #available(iOS 18.0, *) {
                                Chip.rainbow18
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(
                                        ColumnRectangle(column: offset, totalCount: totalCount))
                            } else {
                                Chip.rainbow17
                                    .clipShape(
                                        ColumnRectangle(column: offset, totalCount: totalCount))
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)
                .clipped()

                // Foreground stripes of solid frame colors, with cutouts for textured background
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
                            if let color = value.color, let secondColor = value.prettyColor {
                                // TODO: Fix color.gradient here
                                LinearGradient(
                                    colors: [color, secondColor], startPoint: .top,
                                    endPoint: .bottom
                                )
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
                .shadow(color: Color(uiColor: .systemBackground), radius: 5)
        }
    }
}

#Preview {
    ScrollView {
        ProportionalLazyVGrid {
            FrameColorBackground(frameColors: [.teal, .red, .bareMetal])
            FrameColorBackground(frameColors: [.red, .orange, .yellow])
            FrameColorBackground(frameColors: [.covered, .brown, .black])
            FrameColorBackground(frameColors: [.bareMetal, .white, .covered])
            if #available(iOS 18, *) {
                Chip.rainbow18
            } else {
                Chip.rainbow17
            }
            FrameColorBackground(frameColors: [.green, .blue, .purple])
            Chip.bareMetalAngularGradient
                .frame(
                    minWidth: 100,
                    minHeight: 100,
                )
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}
