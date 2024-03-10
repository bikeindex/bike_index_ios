//
//  ContentLinkViews.swift
//  BikeIndex
//
//  Created by Jack on 12/30/23.
//

import SwiftUI

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
            VStack {
                RoundedRectangle(cornerRadius: 24)
                    .scaledToFit()
                    .foregroundStyle(Color.primary)
                    .overlay {
                        ActionIcon(icon: item.icon)
                            .scaledToFit()
                            .padding()
                    }

                Text(item.title)
            }
        })
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

    var icon: ActionIconResource {
        switch self {
        case .registerBike:
            return .register
        case .alertBike:
            return .alert
        case .search:
            return .search
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
