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
        @Binding var sortOrder: SortOrder

        var body: some ToolbarContent {
            ToolbarItemGroup(placement: .topBarLeading) {
                // Settings
                Button {
                    path.append(MainContent.settings)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .accessibilityHint("Open application settings")

                // Help
                Button {
                    path.append(MainContent.help)
                } label: {
                    Label("Help", systemImage: "book.closed")
                }
                .accessibilityHint("Open frequently asked questions and help pages")
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                if loading {
                    ProgressView()
                        .tint(Color.primary)
                        .accessibilityLabel("Loading indicator")
                }

                Menu {
                    // MARK: - Sorty By
                    Button {
                        sortOrder = sortOrder.toggle()
                    } label: {
                        let systemImage = sortOrder == .forward ? "arrow.down" : "arrow.up"
                        Label("Sort order:", systemImage: systemImage)
                    }
                    .accessibilityValue(sortOrder.displayName)
                    .accessibilityHint("Toggle sort order")
                    Divider()
                    // MARK: - Group By
                    Text("Group by:")
                        .accessibilityLabel("Select one option")
                    ForEach(ViewModel.GroupMode.allCases) { option in
                        let selected = groupMode == option
                        Button {
                            groupMode = option
                            sortOrder = ViewModel.GroupMode.lastKnownSortOrder
                        } label: {
                            if selected {
                                Label(option.displayName, systemImage: "checkmark")
                            } else {
                                Text(option.displayName)
                            }
                        }
                        .accessibilityIdentifier(option.rawValue)
                        .accessibilityHint(Text(selected ? "Currently selected" : "Not selected"))
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .accessibilityLabel("slider-group")
                }
                .accessibilityLabel("Change how bikes are grouped.")
                .accessibilityIdentifier("main_content_page_group_control")
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var groupMode = MainContentPage.ViewModel.GroupMode.byStatus
    @Previewable @State var sortOrder: SortOrder = .forward
    NavigationStack {
        Text("Toolbar preview")
            .toolbar {
                MainContentPage.MainToolbar(
                    path: $path,
                    loading: .constant(true),
                    groupMode: $groupMode,
                    sortOrder: $sortOrder)
            }
    }
    .environment(try! Client())
}
