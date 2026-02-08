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
                Chip(color: bike.frameColorPrimary)

                if let secondary = bike.frameColorSecondary {
                    Chip(color: secondary)
                }

                if let tertiary = bike.frameColorTertiary {
                    Chip(color: tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            Chip.rainbow18
            Chip(color: .covered)
        }
    } else {
        VStack {
            Chip.rainbow17
            Chip(color: .covered)
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
                    Chip(color: frame)
                    Text(frame.displayValue)
                        .font(.caption)
                }
                .padding(2)
            }
        }
    }
}
