//
//  ContentView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    @State var api = API()

    let columnLayout = Array(repeating: GridItem(), count: 2)

    @Query private var bikes: [Bike]
    @Query private var authenticatedUsers: [AuthenticatedUser]

    var body: some View {
        NavigationSplitView {
            ScrollView {
                LazyVGrid(columns: columnLayout) {
                    NavigationLink {
                        AddBikeView()
                    } label: {
                        VStack {
                            RoundedRectangle(cornerRadius: 24)
                                .scaledToFit()
                                .foregroundStyle(Color.primary)
                                .overlay {
                                    HStack {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .scaledToFit()
                                        Image(systemName: "bicycle")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .scaledToFit()
                                    .padding()

                                }

                            Text("Add Bike")
                        }
                    }

                    ForEach(bikes) { bike in
                        Text("Bike \(String(describing: bike.bikeDescription)), \(bike.serial ?? "missing serial number")")
                    }
                }
                .padding()
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
        .task {
            if client.authenticated {
                let myProfile: AuthenticatedUser = await api.get(MeEndpoint.me(config: client.endpointConfig()))
                Logger.views.debug("**NEW** API fetched my profile \(String(describing: myProfile))")
            }
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
         
/*
        ToolbarItem {
            NavigationLink {
                AddBikeView()
            } label: {
                Label("Add Bike", systemImage: "plus")
            }
        }
 */
    }
}

#Preview {
    do {
        let client = try Client()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
                                               configurations: config)

        return ContentView()
            .environment(client)
            .modelContainer(container)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
