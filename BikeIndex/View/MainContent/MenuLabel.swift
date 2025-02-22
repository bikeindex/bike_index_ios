//
//  MenuLabel.swift
//  BikeIndex
//
//  Created by Jack on 2/22/25.
//

import SwiftUI

extension MainContentPage {
    struct MenuLabel: View {
        var title: String

        var body: some View {
            HStack {
                Text(title)
                    .padding(.leading, 10)
                Spacer()
                Text("»")
                    .bold()
                    .padding(.trailing, 10)
            }
        }
    }
}
