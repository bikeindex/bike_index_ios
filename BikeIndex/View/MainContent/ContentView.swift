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

    // Control the navigation hierarchy for all views after this one
    @State var path = NavigationPath()

    // Internal display
    var contentModel = ContentModel()

    @Query private var bikes: [Bike]
    @Query private var authenticatedUsers: [AuthenticatedUser]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                ProportionalLazyVGrid {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in
                        ContentButtonView(path: $path, item: menuItem)
                    }
                }
                .padding()
            }
            .toolbar {
                MainToolbar(path: $path)
            }
            .navigationTitle("Bike Index")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MainContent.self) { selection in
                switch selection {
                case .settings:
                    SettingsView()
                case .registerBike:
                    AddBikeView()
                case .lostBike:
                    Text("Alert a missing bike")
                case .foundBike:
                    Text("Respond to a missing bike")
                }
            }
        }
       .task {
            await contentModel.fetchProfile(client: client, modelContext: modelContext)
        }
    }
}

final class ContentModel {

    @MainActor
    func fetchProfile(client: Client, modelContext: ModelContext) async {
        guard client.authenticated else {
            return
        }

        let fetch_v3_me = await client.api.get(Me.`self`)

        switch fetch_v3_me {
        case .success(let success):
            guard let myProfileSource = success as? AuthenticatedUserResponse else {
                Logger.views.debug("ContentController.fetchProfile failed to parse profile from \(String(reflecting: success), privacy: .public)")
                return
            }

            let myProfile = myProfileSource.modelInstance()
            myProfile.user = myProfileSource.user.modelInstance()

            modelContext.insert(myProfile)

        case .failure(let failure):
            Logger.views.error("\(type(of: self)).\(#function) - Failed with \(failure)")
        }
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
