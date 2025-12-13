//
//  Chip.swift
//  BikeIndex
//
//  Created by Jack on 12/12/25.
//

import Flow
import SwiftUI

struct Chip: View {
    /// In the absence of `title`, frameColor will be displayed
    let title: String?
    let color: FrameColor
    let style: ChipStyle

    private let radius = 6.0
    private let stroke = 4.0

    init(title: String? = nil, color: FrameColor, style: ChipStyle = .roundedLabel) {
        self.title = title
        self.color = color
        self.style = style
    }

    var body: some View {
        ZStack {
            switch (style, color) {
            // Bare Metal
            case (.roundedLabel, .bareMetal):
                roundedLabel
                    .stroke(
                        Self.bareMetalAngularGradient,
                        lineWidth: stroke / 2)
            case (.circle, .bareMetal):
                circle
                    .stroke(
                        Self.bareMetalAngularGradient,
                        lineWidth: stroke / 2)
            // Covered
            case (.roundedLabel, .covered):
                if #available(iOS 18.0, *) {
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(
                            Self.rainbow18,
                            lineWidth: stroke / 2)
                } else {
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(
                            Self.rainbow17,
                            lineWidth: stroke / 2)
                }
            case (.circle, .covered):
                if #available(iOS 18.0, *) {
                    circle.fill(Self.rainbow18)
                } else {
                    circle.fill(Self.rainbow17)
                }
            // Color with value
            case (.roundedLabel, let value):
                roundedLabel
                    .stroke(
                        value.color!.gradient,
                        lineWidth: stroke
                    )
                    .fill(.background.tertiary)
            case (.circle, let value):
                circle
                    .fill(value.color!)
            }

            if style == .roundedLabel {
                Text(title ?? color.displayValue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .fixedSize()
    }

    var roundedLabel: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius)
    }

    var circle: Circle {
        Circle()
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
    static var rainbow18: MeshGradient {
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

    static var rainbow17: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
            center: .center)
    }
}

// MARK: -

enum ChipStyle {
    case roundedLabel
    case circle
}

// MARK: -

struct ChipStyleModifier: ViewModifier {
    let title: String?
    let color: FrameColor
    let style: ChipStyle

    func body(content: Content) -> some View {
        Chip(title: title, color: color, style: style)
    }
}

extension Chip {
    func style(_ style: ChipStyle) -> Chip {
        Chip(title: title, color: color, style: style)
    }
}

// MARK:

#Preview {
    Chip(color: .blue)
        .style(.roundedLabel)

    Chip(color: .red)
        .style(.circle)

    // Edge-case
    Chip(color: .covered)
        .style(.circle)
}

#Preview("Chip") {
    ZStack {
        VStack {
            ForEach(FrameColor.allCases) { frame in
                HStack {
                    Chip(color: frame)
                    Spacer()
                    Chip(color: frame)
                        .style(.circle)
                }
            }
        }
    }
}
