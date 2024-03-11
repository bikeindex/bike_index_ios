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
    @Environment(\.colorScheme) var colorScheme

    // Control the navigation hierarchy for all views after this one
    @State var path = NavigationPath()

    // Internal display
    var contentModel = ContentModel()

    @Query private var bikes: [Bike]
    @Query private var authenticatedUsers: [AuthenticatedUser]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                    ForEach(ContentButton.allCases, id: \.id) { menuItem in

                        Button(action: {

                        }, label: {
                            Text(menuItem.title)
                                .padding(.leading, 10)
                            Spacer()
                            Text("»")
                                .bold()
                                .padding(.trailing, 10)
                        })
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .tint(.white)
                        .background(colorScheme == .light ? .black : .secondary)
                        .padding(.horizontal, 8)
                    }
                }

                ProportionalLazyVGrid {
                    ForEach(Array(bikes.enumerated()), id: \.element) { (index, bike) in
                        ContentBikeButtonView(path: $path, bike: bike)
                            .accessibilityIdentifier("Bike \(index + 1)")
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
                        .accessibilityIdentifier("Settings")
                case .registerBike:
                    RegisterBikeView(mode: .myOwnBike)
                case .lostBike:
                    RegisterBikeView(mode: .myStolenBike)
                case .searchBikes:
                    NavigableWebView(url: URL(string: "https://bikeindex.org/bikes?stolenness=all"))
                        .environment(client)
                }
            }
            .navigationDestination(for: PersistentIdentifier.self) { identifier in
                if let bike = bikes.first(where: { $0.persistentModelID == identifier }) {
                    BikeDetailView(bike: bike)
                }
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
