//
//  DisplayProportion.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import SwiftUI

/// Display LazyVGrid content of equal-sized squares in the right proportion across any device size
struct ProportionalLazyVGrid<Content>: View where Content: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @ViewBuilder
    var content: () -> Content

    var body: some View {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if horizontalSizeClass == .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                    content()
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                    content()
                }
            }
        case .pad:
            if horizontalSizeClass == .compact || verticalSizeClass == .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                    content()
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                    content()
                }
            }
        default:
            LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                content()
            }
        }
    }
}
