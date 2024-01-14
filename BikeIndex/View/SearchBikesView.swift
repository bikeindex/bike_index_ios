//
//  SearchBikesView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData

protocol SearchValue {
    var value: String { get }
}

protocol Displayable {
    var display: any View { get }
}

/// Represents auto-completable 'chips' that are distinct UI elements
enum SearchTerm: SearchValue, Displayable {
    case color(FrameColor)
    case motorized // aka electric
    case manufacturer(AutocompleteManufacturer) // TODO: Replace with canonical Manufacturer model
    case type(BicycleType)

    var value: String {
        switch self {
        case .color(let color):
            return color.displayValue
        case .motorized:
            return "Motorized"
        case .manufacturer(let manufacturer):
            return manufacturer.text
        case .type(let type):
            return type.name
        }
    }

    var display: any View {
        return Text(self.value)
    }
}

struct SearchBikesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    @Binding var searchTerms: [SearchTerm]
    @Binding var serialNumberSearch: String
    @Binding var searchMode: GlobalSearchMode
    @Query var bikeQueryResults: [Bike]

    var body: some View {
        Section {
            List {
                ForEach(bikeQueryResults) { bike in
                    VStack {
                        Text(bike.bikeDescription ?? "<empty>")
                        if let location = bike.stolenLocation {
                            Text(location)
                        }
                    }
                }
            }
        } header: {
            HStack {
                VStack {
                    TextField(text: $serialNumberSearch) {
                        Text("Search bike descriptions")
                    }

                    TextField(text: $serialNumberSearch) {
                        Text("_Search for serial number_")
                    }
                }
                .padding(.leading, 8)

                Button(action: {
//                    client.queryGlobal(
//                        // fill in endpoint and params
//                        context: modelContext
//                    )
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(18)
                        .accessibilityLabel("Search")
                        .frame(maxWidth: 60)
                        .frame(maxHeight: 60)
                        .scaledToFill()
                })
                .foregroundStyle(Color.white)
                .background(Color.blue)
                .padding(.trailing, 8)
            }


            // TODO: Replace this with our own vertical picker
            VerticalPicker(activeMode: $searchMode)
        } footer: {
            Text("No more results")
        }

        .navigationTitle(Text("Search Bikes"))
    }
}

#Preview {
    do {
        let client = try Client()

        return NavigationStack {
            SearchBikesView(searchTerms: .constant([.color(.red)]),
                            serialNumberSearch: .constant(""),
                            searchMode: .constant(.withinHundredMiles))
                .environment(client)
                .modelContainer(for: Bike.self,
                                inMemory: true,
                                isAutosaveEnabled: false)
        }
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
