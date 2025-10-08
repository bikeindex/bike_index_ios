//
//  Image+Icon.swift
//  BikeIndex
//
//  Created by Jack on 9/1/25.
//

import SwiftUI

extension Image {
    func appIcon(scale: AppIconView.Scale = .large) -> some View {
        self.resizable()
            .modifier(AppIconView(scale: scale))
    }
}
