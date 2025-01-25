//
//  AppIconPicker.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
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

extension Image {
    func appIcon(scale: AppIconView.Scale = .large) -> some View {
        self.resizable()
            .modifier(AppIconView(scale: scale))
    }
}

/// Validates Views with UIImages (without using models)
#Preview("App Icon Direct UIImage Access") {
    VStack {
        Form {
            Section {
                Image(uiImage: UIImage(named: "AppIcon-in-app").unsafelyUnwrapped)
                    .appIcon(scale: .large)

                Label(
                    title: { Text("App Icon") },
                    icon: {
                        Image(uiImage: UIImage(named: "AppIcon-in-app").unsafelyUnwrapped)
                            .appIcon(scale: .small)
                    }
                )
            }
        }
    }
}

struct AppIconPicker: View {
    @Binding var model: AlternateIconsModel

    var body: some View {
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
        .toolbar(content: {
            ToolbarItem(placement: .status) {
                Text("Choose your own app icon")
            }
        })
        .navigationTitle("App Icon")
    }
}

#Preview("App Icon Picker View") {
    NavigationStack {
        AppIconPicker(model: .constant(AlternateIconsModel()))
    }
}
