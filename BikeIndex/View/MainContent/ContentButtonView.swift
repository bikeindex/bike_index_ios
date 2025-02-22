//
//  ContentLinkViews.swift
//  BikeIndex
//
//  Created by Jack on 12/30/23.
//

import SwiftUI

extension MainContentPage {
    struct MenuButtonStyle: ButtonStyle {
        @Environment(\.colorScheme) var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity,
                       minHeight: 40,
                       maxHeight: 80)
                .foregroundStyle(.white)
                .background(colorScheme == .light ? .black : .secondary)
                .padding(.horizontal, 8)
        }
    }

    struct ContentButtonView: View {
        @Binding var path: NavigationPath
        var item: ContentButton

        var body: some View {
            Button(action: {
                switch item {
                case .registerBike:
                    path.append(MainContent.registerBike)
                case .alertBike:
                    path.append(MainContent.lostBike)
                case .search:
                    path.append(MainContent.searchBikes)
                }
            }, label: {
                MenuLabel(title: item.title)
            })
            .buttonStyle(MainContentPage.MenuButtonStyle())
            .accessibilityIdentifier(item.title)
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

        var icon: ImageResource {
            switch self {
            case .registerBike:
                return .iconRegister
            case .alertBike:
                return .iconAlert
            case .search:
                return .stolenRegistry
            }
        }

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
}

#Preview("All Content Button Previews") {
    let path: Binding = .constant(NavigationPath())
    ScrollView {
        ForEach(MainContentPage.ContentButton.allCases) { item in
            MainContentPage.ContentButtonView(path: path, item: item)
        }
    }
}
