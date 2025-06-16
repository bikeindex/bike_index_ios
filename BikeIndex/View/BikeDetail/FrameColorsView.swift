//
//  FrameColorsView.swift
//  BikeIndex
//
//  Created by Jack on 6/15/25.
//

import SwiftUI

struct FrameColorsView: View {
    var bike: Bike
    var body: some View {
        HStack {
            Text(bike.frameColors.count > 1 ? "Frame Colors" : "Frame Color")
            Spacer()

            FrameColorShapeView(frame: bike.frameColorPrimary)
                .frame(maxWidth: 30)
            if let secondary = bike.frameColorSecondary {
                FrameColorShapeView(frame: secondary)
                    .frame(maxWidth: 30)
            }
            if let tertiary = bike.frameColorTertiary {
                FrameColorShapeView(frame: tertiary)
                    .frame(maxWidth: 30)
            }
        }
        .frame(maxHeight: 30)
    }
}

extension Color {
    static let dimWhite = Color(white: 0.75)
    static let darkGray = Color(white: 0.25)
    static let lightGray = Color(white: 0.59)
    static let almostBlack = Color(white: 0.1)
}

struct FrameColorShapeView: View {
    let frame: FrameColor

    //    static var bareMetalAngleGradient: AngularGradient {
    //        AngularGradient(stops: [
    //            .init(color: .dimWhite, location: 0.0),
    //            .init(color: .gray, location: 0.04),
    //            .init(color: .almostBlack, location: 0.08),
    //
    //            .init(color: .darkGray, location: 0.12),
    //            .init(color: .gray, location: 0.2),
    //            .init(color: .almostBlack, location: 0.24),
    //            .init(color: .dimWhite, location: 0.29),
    //
    //            .init(color: .almostBlack, location: 0.3),
    //            .init(color: .gray, location: 0.35),
    //            .init(color: .darkGray, location: 0.39),
    //
    //            .init(color: .almostBlack, location: 0.42),
    //
    //            .init(color: .gray, location: 0.5),
    //            .init(color: .almostBlack, location: 0.59),
    //            .init(color: .gray, location: 0.6),
    //
    //            .init(color: .almostBlack, location: 0.69),
    //            .init(color: .gray, location: 0.75),
    //            .init(color: .almostBlack, location: 0.81),
    //
    //            .init(color: .gray, location: 0.89),
    //            .init(color: .almostBlack, location: 0.95),
    //            .init(color: .dimWhite, location: 1.0),
    //        ], center: .center)
    //    }

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

    let radius = 2.0
    let shadow = Color.primary.opacity(0.6)
    let stroke = 9.0

    var body: some View {
        Group {
            if let color = frame.color {
                Circle()
                    .fill(color)
            } else if frame == .bareMetal {
                Circle()
                    .fill(Self.bareMetalAngularGradient)
            } else {
                // covered
                if #available(iOS 18.0, *) {
                    Circle()
                        .fill(.foreground)
                        .strokeBorder(Self.rainbow, lineWidth: stroke)
                } else {
                    Circle()
                        .fill(.foreground)
                        .strokeBorder(Self.rainbow2, lineWidth: stroke)
                }
            }
        }
        .accessibilityLabel(frame.displayValue)
        .accessibilityHint("Frame color indicator")
        .compositingGroup()
        .shadow(
            color: shadow,
            radius: radius)

    }
}

extension FrameColor {
    var color: Color? {
        switch self {
        case .bareMetal, .covered:
            nil
        case .black:
            .black
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
            .white
        case .yellow:
            .yellow
        }
    }
}

// let rainbow = AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)

#Preview {
    @Previewable let bike = Bike.init(
        identifier: 1_234_567_890,
        primaryColor: .blue,
        secondaryColor: .bareMetal,
        tertiaryColor: .covered,
        manufacturerName: "",
        typeOfCycle: .bike,
        typeOfPropulsion: .footPedal,
        status: .withOwner,
        stolenCoordinateLatitude: 0.0,
        stolenCoordinateLongitude: 0.0,
        url: URL(stringLiteral: "about:blank"),
        publicImages: [])
    Text("Shadows fit better in BikeDetailOfflineView")
    FrameColorsView(bike: bike)
}

#Preview("Rainbow iOS 18 Mesh") {
    if #available(iOS 18.0, *) {
        VStack {
            FrameColorShapeView.rainbow
            FrameColorShapeView(frame: .covered)
        }
    } else {
        VStack {
            FrameColorShapeView.rainbow2
            FrameColorShapeView(frame: .covered)
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
                    FrameColorShapeView(frame: frame)
                    Text(frame.displayValue)
                        .font(.caption)
                }
                .padding(2)
            }
        }
    }
}
