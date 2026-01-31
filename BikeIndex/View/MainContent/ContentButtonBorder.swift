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
                            if let color = value.color {
                                // TODO: Fix color.gradient here
                                LinearGradient(
                                    colors: [color], startPoint: .leading, endPoint: .trailing
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
            ContentButtonBorder(frameColors: [.covered, .brown, .black])
            ContentButtonBorder(frameColors: [.bareMetal, .covered])
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

struct ColumnRectangle: Shape {
    /// The "position index" that the Shape receiving this `.clippedShape(BifurcatedRectangle())` **should** display within
    var column: Int
    var totalCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)

        let colWidth = rect.width / CGFloat(totalCount)
        for layoutColumn in 0..<totalCount where layoutColumn != column {
            let clipRect = CGRect(
                x: colWidth * CGFloat(layoutColumn),
                y: rect.origin.y,
                width: colWidth,
                height: rect.height)
            var clipPath = Path()
            clipPath.addRect(clipRect)
            path = path.subtracting(clipPath)
            print("Evaluating layout column", layoutColumn, clipRect)
        }

        return path
    }
}

#Preview {
    VStack(spacing: 0) {
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 0, totalCount: 3))
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 1, totalCount: 3))
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 2, totalCount: 3))
    }
    .background(.yellow)
}
