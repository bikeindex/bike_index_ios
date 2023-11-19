//
//  ContentView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    @Query private var bikes: [Bike]
    @Query private var authenticatedUsers: [AuthenticatedUser]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(bikes) { bike in
                    Text("Bike \(String(describing: bike.bikeDescription)), \(bike.serial ?? "missing serial number")")
                }
            }

#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                MainToolbar()
            }
            .navigationTitle(Text(authenticatedUsers.first?.user.name ?? "No user found"))
        } detail: {
            Text("Select an item")
        }
    }
}

struct MainToolbar: ToolbarContent {
    @State var searchTerms: [SearchTerm] = []
    @State var serialNumberSearch: String = ""
    @State var searchMode: GlobalSearchMode = .withinHundredMiles

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }

        /*
         // The search UI is not ready yet
        ToolbarItem {
            NavigationLink {
                SearchBikesView(searchTerms: $searchTerms,
                                serialNumberSearch: $serialNumberSearch,
                                searchMode: $searchMode)
            } label: {
                Label("Search Bikes", systemImage: "magnifyingglass")
            }
        }
         */

        ToolbarItem {
            NavigationLink {
                AddBikeView()
            } label: {
                Label("Add Bike", systemImage: "plus")
            }
        }
    }
}

// TODO: Fix this from crashing
#Preview {
    do {
        let client = try Client()
        return ContentView()
            .environment(client)
            .modelContainer(for: Bike.self,
                            inMemory: true,
                            isAutosaveEnabled: false)
            .modelContainer(for: AuthenticatedUser.self,
                            inMemory: true,
                            isAutosaveEnabled: false)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
