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
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(.constant(frameColors), id: \.id) { frame in
                    switch frame.wrappedValue {
                    case .bareMetal:
                        // Bare Metal
                        Rectangle()
                            .overlay {
                                Chip.bareMetalAngularGradient
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                                    .zIndex(-100)
                            }
                    case .covered:
                        // Covered
                        if #available(iOS 18.0, *) {
                            Rectangle()
                                .overlay {
                                    Chip.rainbow18
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .onAppear { print("@@", geo.size) }
                                }
                                .clipped()
                        } else {
                            Chip.rainbow17
                        }
                    case (let value):
                        // Color with value
                        if let color = value.color {
                            // TODO: Fix color.gradient here
                            LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing)
                                .zIndex(100)
                        } else {
                            Text("Inconsident FrameColor usage")
                        }
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
            ContentButtonBorder(frameColors: [.blue, .red, .bareMetal])
            ContentButtonBorder(frameColors: [.red, .orange, .yellow])
            ContentButtonBorder(frameColors: [.white, .black, .covered])
            ContentButtonBorder(frameColors: [.white])
            if #available(iOS 18, *) {
                Chip.rainbow18
            } else {
                Chip.rainbow17
            }
            ContentButtonBorder(frameColors: [.green, .blue, .purple])
        }
    }
}
