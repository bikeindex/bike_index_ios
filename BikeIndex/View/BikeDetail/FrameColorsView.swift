//
//  FrameColorsView.swift
//  BikeIndex
//
//  Created by Jack on 6/15/25.
//

import Flow
import SwiftUI

struct FrameColorsView: View {
    var bike: Bike
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(bike.frameColors.count > 1 ? "Frame Colors" : "Frame Color")
                .detailTitle()
                .fixedSize()
                .padding([.leading, .bottom], 6)

            HFlow(
                horizontalAlignment: .leading,
                verticalAlignment: .top
            ) {
                Chip(frame: bike.frameColorPrimary)

                if let secondary = bike.frameColorSecondary {
                    Chip(frame: secondary)
                }

                if let tertiary = bike.frameColorTertiary {
                    Chip(frame: tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension FrameColor {
    var color: Color? {
        switch self {
        case .bareMetal, .covered:
            nil
        case .black:
            // slightly lighter than pure black for display
            Color(white: 0.1)
        case .blue:
            .blue
        case .brown:
            .brown
        case .green:
            .green
        case .orange:
            .orange
        case .pink:
            .pink
        case .purple:
            .purple
        case .red:
            .red
        case .teal:
            .teal
        case .white:
            // Slightly darker than pure white for display
            Color(white: 0.9)
        case .yellow:
            .yellow
        }
    }
}

extension Color {
    static let dimWhite = Color(white: 0.75)
    static let darkGray = Color(white: 0.25)
    static let lightGray = Color(white: 0.59)
    static let almostBlack = Color(white: 0.1)
}

#Preview("FrameColorsView Prime") {
    @Previewable let bike = Bike.init(
        identifier: 1_234_567_890,
        primaryColor: .blue,
        secondaryColor: .pink,
        tertiaryColor: .bareMetal,
        manufacturerName: "",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0.0,
        stolenCoordinateLongitude: 0.0,
        url: URL(stringLiteral: "about:blank"),
        publicImages: [])
    VStack {
        Text("Shadows fit better in BikeDetailOfflineView")
        FrameColorsView(bike: bike)
        Spacer()
    }
}

#Preview("Rainbow iOS 18 Mesh") {
    if #available(iOS 18.0, *) {
        VStack {
            Chip.rainbow
            Chip(frame: .covered)
        }
    } else {
        VStack {
            Chip.rainbow2
            Chip(frame: .covered)
        }
    }
}

#Preview("Frame Color Contact Sheet") {
    Text("Shadows fit better in BikeDetailOfflineView")
    ScrollView {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(),
                count: 3)
        ) {
            ForEach(FrameColor.allCases) { frame in
                VStack {
                    Chip(frame: frame)
                    Text(frame.displayValue)
                        .font(.caption)
                }
                .padding(2)
            }
        }
    }
}

// MARK: - New approach

struct Chip: View {
    let frame: FrameColor

    private let radius = 6.0
    private let stroke = 4.0

    var body: some View {
        ZStack {
            if let color = frame.color {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        color.gradient,
                        lineWidth: stroke
                    )
                    .fill(.background.tertiary)
            } else if frame == .bareMetal {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        Self.bareMetalAngularGradient,
                        lineWidth: stroke / 2)
            } else {
                // covered
                if #available(iOS 18.0, *) {
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(
                            Self.rainbow,
                            lineWidth: stroke / 2)
                } else {
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(
                            Self.rainbow2,
                            lineWidth: stroke / 2)
                }
            }

            Text(frame.displayValue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .fixedSize()
    }

    static var bareMetalGradient: LinearGradient {
        let base: [Color] = [
            .darkGray,
            .almostBlack,
            .gray,
            .almostBlack,
            .darkGray,
            .gray,
            .almostBlack,
        ]
        let colors = Array(repeating: base, count: 3)
            .flatMap { $0 }
        return LinearGradient(
            colors: colors,
            startPoint: .bottomLeading,
            endPoint: .topTrailing)
    }

    static var bareMetalAngularGradient: AngularGradient {
        let base: [Color] = [
            .darkGray,
            .almostBlack,
            .gray,
            .dimWhite,
            .almostBlack,
            .darkGray,
            .gray,
            .almostBlack,
            .lightGray,
        ]
        let colors = Array(repeating: base, count: 2)
            .flatMap { $0 }
        return AngularGradient(colors: colors, center: .center)
    }

    @available(iOS 18.0, *)
    static var rainbow: MeshGradient {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.6, 0.7], [1, 0.5],
                [0, 1], [0.1, 1], [1, 1],
            ],
            colors: [
                .red, .orange, .yellow,
                .blue, .red, .green,
                .accent, .purple, .highlightPrimary,
            ])
    }

    static var rainbow2: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
            center: .center)
    }
}

#Preview("Chip") {
    ZStack {
//        Color.pink
        VStack {
            ForEach(FrameColor.allCases) { frame in
                Chip(frame: frame)
            }
        }
    }
}
