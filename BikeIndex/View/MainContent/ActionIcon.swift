//
//  ActionButton.swift
//  BikeIndex
//
//  Created by Jack on 11/23/23.
//

import SwiftUI

enum ActionIconResource: String {
    case register = "icon_register"
    case recover = "icon_recover"
    case alert = "icon_alert"
    case responds = "icon_responds"
    case search = "stolen-registry"

    var image: UIImage? {
        UIImage(named: self.rawValue)
    }
}

struct ActionIcon: View {
    var icon: ActionIconResource

    var body: some View {
        if let image = icon.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "questionmark.app.dashed")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    ActionIcon(icon: .register)
}
