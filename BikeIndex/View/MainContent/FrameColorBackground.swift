//
//  FrameColorBackground.swift
//  BikeIndex
//
//  Created by Jack on 1/22/26.
//

import SwiftUI

struct FrameColorBackground: View {
    var frameColors: [FrameColor]

    var body: some View {
        // Fill the parent-proposed size; do not self-size via GeometryReader+aspectRatio,
        // which fed the scroll content size back into itself and caused a layout loop.
        ZStack {
            // Textured FrameColor background IF applicable
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
        .clipped()
        .overlay {
            // Solid color stripes with cutouts for the textured (bareMetal/covered) columns.
            let totalCount = frameColors.count
            ForEach(Array(frameColors.enumerated()), id: \.element.id) { (offset, frame) in
                if !isTextured(frame) {
                    LinearGradient(
                        colors: frame.gradientColors, startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(ColumnRectangle(column: offset, totalCount: totalCount))
                }
            }
        }
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

    /// `bareMetal` and `covered` render as a textured background with a cutout in
    /// the foreground stripe layer; every other color is a solid gradient stripe.
    private func isTextured(_ frame: FrameColor) -> Bool {
        switch frame {
        case .bareMetal, .covered:
            return true
        default:
            return false
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
