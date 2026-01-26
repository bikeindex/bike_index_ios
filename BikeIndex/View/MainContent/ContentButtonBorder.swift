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
struct ContentButtonBorder: View {
    var frameColors: [FrameColor]

    var body: some View {
        HStack {
            ForEach(.constant(frameColors), id: \.id) { frame in

                switch frame.wrappedValue {
                // Bare Metal
                case .bareMetal:
                    Chip.bareMetalAngularGradient
                // Covered
                case .covered:
                    if #available(iOS 18.0, *) {
                        Chip.rainbow18
                    } else {
                        Chip.rainbow17
                    }
                // Color with value
                case (let value):
                    if let color = value.color {
                        // Cannot convert value of type 'Color?' to expected element type 'Array<Color>.ArrayLiteralElement' (aka 'Color')
                        LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing)
                    } else {
                        Text("Inconsident FrameColor usage")
                    }
                }
            }
        }

        .cornerRadius(24)
        .overlay {
            Image(systemName: "bicycle")
                .resizable()
                .scaledToFit()
                .padding()
                .tint(.secondary)
                .foregroundStyle(.primary)
                .shadow(color: Color(uiColor: .systemBackground), radius: 5)

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
