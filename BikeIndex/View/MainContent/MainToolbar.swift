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
            ToolbarItemGroup(placement: .topBarLeading) {
                // Settings
                Button {
                    path.append(MainContent.settings)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                // Help
                Button {
                    path.append(MainContent.help)
                } label: {
                    Label("Help", systemImage: "book.closed")
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
                    Text("Group by:")
                        .accessibilityLabel("Select one option")
                    ForEach(ViewModel.GroupMode.allCases) { option in
                        Button {
                            groupMode = option
                        } label: {
                            if groupMode == option {
                                Label(option.displayName, systemImage: "checkmark")
                                    .accessibilityHint(Text("Currently selected"))
                            } else {
                                Text(option.displayName)
                                    .accessibilityHint(Text("Not selected"))
                            }
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .accessibilityLabel("Change how bikes are grouped.")
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
