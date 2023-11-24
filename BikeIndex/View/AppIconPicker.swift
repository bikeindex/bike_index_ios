//
//  AppIconPicker.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import OSLog

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
    }

    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: scale.size))
            .shadow(radius: 4)
    }
}

extension Image {
    func appIcon(scale: AppIconView.Scale = .large) -> some View {
        self.resizable()
            .modifier(AppIconView(scale: scale))
    }
}

#Preview {
    VStack {
        Form {
            Section {
                Image(uiImage: UIImage(named: "AppIcon").unsafelyUnwrapped)
                    .appIcon(scale: .large)

                Label(
                    title: { Text("App Icon") },
                    icon: {
                        Image(uiImage: UIImage(named: "AppIcon").unsafelyUnwrapped)
                        .appIcon(scale: .small)
                    }
                )
            }
        }
    }
}

struct AppIconPicker: View {
    let columnLayout = Array(repeating: GridItem(), count: 2)

    @Binding var model: AlternateIconsModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columnLayout) {
                ForEach(AppIcon.allCases, id: \.id) { icon in
                    Button {
                        model.update(icon: icon)
                    } label: {
                        VStack {
                            if let uiImage = UIImage(named: icon.rawValue) {
                                Image(uiImage: uiImage)
                                    .appIcon()
                            } else {
                                Image(systemName: model.absentIcon)
                                    .appIcon()
                            }
                            Text(icon.description)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("App Icon")
    }
}

#Preview {
    AppIconPicker(model: .constant(AlternateIconsModel()))
}
