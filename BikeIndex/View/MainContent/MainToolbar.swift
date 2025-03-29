//
//  MainToolbar.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import SwiftUI

/// Toolbar for authenticated users on the regular ``MainContentPage``.
struct MainToolbar: ToolbarContent {
    @Binding var path: NavigationPath

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
    }
}

#Preview {
    NavigationStack {
        Text("MainToolbar")
            .toolbar {
                MainToolbar(path: .constant(NavigationPath()))
            }
    }
}
