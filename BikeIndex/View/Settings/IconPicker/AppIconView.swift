//
//  AppIconView.swift
//  BikeIndex
//
//  Created by Jack on 9/1/25.
//

import SwiftUI

struct AppIconView: ViewModifier {
    var scale: Scale

    enum Scale {
        case small
        case large

        var size: CGFloat {
            switch self {
            case .small:
                return 8
            case .large:
                return 24
            }
        }

        var shadow: CGFloat {
            switch self {
            case .small:
                0.5
            case .large:
                4
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: scale.size))
            .shadow(color: .primary, radius: scale.shadow)
    }
}
