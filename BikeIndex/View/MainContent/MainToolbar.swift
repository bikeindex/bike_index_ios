//
//  MainToolbar.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import SwiftUI

extension MainContentPage {
    struct MainToolbar: ToolbarContent {
        @Environment(Client.self) var client

        @Binding var path: NavigationPath
        @Binding var loading: Bool
        @Binding var groupMode: ViewModel.GroupMode

        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.append(MainContent.settings)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }

            if loading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Color.primary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ViewModel.GroupMode.allCases) { option in
                        Button(option.displayName) {
                            groupMode = option
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var groupMode = MainContentPage.ViewModel.GroupMode.byStatus
    NavigationStack {
        Text("Toolbar preview")
            .toolbar {
                MainContentPage.MainToolbar(
                    path: $path,
                    loading: .constant(true),
                    groupMode: $groupMode)
            }
    }
    .environment(try! Client())
}
