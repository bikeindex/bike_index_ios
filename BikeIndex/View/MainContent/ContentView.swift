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
                    ForEach(bikes) { bike in
                        ContentBikeButtonView(path: $path, bike: bike)
                    }
                }
                .padding()
            }
            .toolbar {
                MainToolbar(path: $path)
            }
            .navigationTitle("Bike Index")
            .navigationDestination(for: MainContent.self) { selection in
                switch selection {
                case .settings:
                    SettingsView()
                case .registerBike:
                    RegisterBikeView(mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(mode: .myStolenBike)
                case .foundBike:
                    RegisterBikeView(mode: .abandonedBike)
                }
            }
            .navigationDestination(for: Bike.self) { bike in
                BikeDetailView(bike: bike)
            }
        }
       .task {
           await contentModel.fetchProfile(client: client,
                                           modelContext: modelContext)
           await contentModel.fetchBikes(client: client,
                                         modelContext: modelContext)
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
                Logger.model.debug("ContentController.fetchProfile failed to parse profile from \(String(reflecting: success), privacy: .public)")
                return
            }

            let myProfile = myProfileSource.modelInstance()
            myProfile.user = myProfileSource.user.modelInstance()

            modelContext.insert(myProfile)

        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
        }
    }

    @MainActor
    func fetchBikes(client: Client, modelContext: ModelContext) async {
        guard client.authenticated else {
            return
        }

        let fetchMyBikes = await client.api.get(Me.bikes)

        switch fetchMyBikes {
        case .success(let success):
            guard let myBikesSource = success as? MultipleBikeResponseContainer else {
                Logger.model.debug("ContentController.fetchBikes failed to parse bikes from \(String(reflecting: success), privacy: .public)")
                return
            }

            for bike in myBikesSource.bikes {
                let model = bike.modelInstance()
                modelContext.insert(model)
            }

        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
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
