//
//  AppIconPicker.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftUI

/// UIImage will handle light / dark mode asset switching automatically
struct AppIconPicker: View {
    @Binding var model: AlternateIconsModel

    var body: some View {

        ZStack(alignment: .bottom) {
            ScrollView {
                ProportionalLazyVGrid {
                    ForEach(AppIcon.allCases, id: \.id) { icon in
                        Button {
                            model.update(icon: icon)
                        } label: {
                            VStack {
                                Image(uiImage: icon.image)
                                    .appIcon()
                                Text(icon.description)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                    }
                }
                .padding()
            }
            Text("Choose your own app icon")
                .fontWeight(.medium)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("App Icon Picker View") {
    NavigationStack {
        AppIconPicker(model: .constant(AlternateIconsModel()))
    }
}
