//
//  ContentLinkViews.swift
//  BikeIndex
//
//  Created by Jack on 12/30/23.
//

import SwiftUI

struct ContentButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var path: NavigationPath
    var item: ContentButton

    var body: some View {
        Button(
            action: {
                switch item {
                case .registerBike:
                    path.append(MainContent.registerBike)
                case .alertBike:
                    path.append(MainContent.lostBike)
                case .search:
                    path.append(MainContent.searchBikes)
                }
            },
            label: {
                Text(item.title)
                    .padding(.leading, 10)
                Spacer()
                Text("»")
                    .bold()
                    .padding(.trailing, 10)
            }
        )
        .accessibilityIdentifier(item.title)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, minHeight: 40)
        .tint(.white)
        .background(colorScheme == .light ? .black : .secondary)
        .padding(.horizontal, 8)
    }
}

enum ContentButton: String, Identifiable, Codable, CaseIterable {
    var id: String { self.rawValue }

    /// This is my bike
    case registerBike
    /// I lost my bike
    case alertBike
    /// Search!
    case search

    var title: String {
        switch self {
        case .registerBike:
            return "Register a bike"
        case .alertBike:
            return "Register a stolen bike"
        case .search:
            return "Search"
        }
    }
}
