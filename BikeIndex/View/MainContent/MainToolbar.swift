//
//  MainToolbar.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import SwiftUI

struct MainToolbar: ToolbarContent {
    @State var searchTerms: [SearchTerm] = []
    @State var serialNumberSearch: String = ""
    @State var searchMode: GlobalSearchMode = .withinHundredMiles
    @Binding var path: NavigationPath

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                path.append(MainContent.settings)
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}
