//
//  ManufacturerEntryView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData

struct ManufacturerEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    @Binding var bike: Bike
    @Binding var manufacturerSearchText: String
    @Binding var searching: Bool

    @Query var manufacturers: [AutocompleteManufacturer]

    init(bike: Binding<Bike>, manufacturerSearchText: Binding<String>, searching: Binding<Bool>) {
        _bike = bike
        _manufacturerSearchText = manufacturerSearchText
        _searching = searching
        let searchTerm = manufacturerSearchText.wrappedValue

        let predicate = #Predicate<AutocompleteManufacturer> { model in
            model.text.contains(searchTerm)
        }

        var descriptor = FetchDescriptor<AutocompleteManufacturer>(predicate: predicate)
        descriptor.fetchLimit = 10

        _manufacturers = Query(descriptor)
    }

    var body: some View {
        if searching {
            TextField(text: $manufacturerSearchText) {
                Text("Search for manufacturer")
            }
            .onChange(of: manufacturerSearchText) { oldValue, newValue in
                guard !newValue.isEmpty else {
                    return
                }

                client.query(manufacturer: newValue, context: modelContext)
            }
            if !manufacturerSearchText.isEmpty {
                List {
                    ForEach(manufacturers) { manufacturer in
                        Text(manufacturer.text)
                            .foregroundStyle(Color.secondary)
                            .onTapGesture {
                                bike.manufacturerName = manufacturer.text
                                manufacturerSearchText = manufacturer.text
                                searching = false
                            }
                    }
                }
                .padding([.leading, .trailing], 8)
            }
        } else {
            TextField(text: $manufacturerSearchText) {
                Text("Search for manufacturer")
            }.onChange(of: manufacturerSearchText, { _, _ in
                searching = true
            })
        }
    }
}

/// NOTE: These bindings are not working correctly
#Preview {
    var previewBike: Bike = Bike()
    let bikeBinding = Binding {
        previewBike
    } set: { newValue in
        previewBike = newValue
    }

    var searchText = ""
    let searchTextBinding = Binding(get: {
        searchText
    }, set: {
        searchText = $0
    })

    var searching = true
    let searchBinding = Binding(get: { searching }, set: { searching = $0 })

    do {
        let client = try Client()
        
        let mockAutocompleteManufacturers = [
            AutocompleteManufacturer(text: "Aaaaaaaa", category: "", slug: "aaa", priority: 1, searchId: "aaa", identifier: 1),
            AutocompleteManufacturer(text: "Bbbbbbbb", category: "", slug: "bbb", priority: 1, searchId: "bbb", identifier: 1),
            AutocompleteManufacturer(text: "Cccccccc", category: "", slug: "ccc", priority: 1, searchId: "ccc", identifier: 1),
        ]

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(for: AutocompleteManufacturer.self, configurations: config)

        mockAutocompleteManufacturers.forEach { manufacturer in
            mockContainer.mainContext.insert(manufacturer)
        }

        return Section {
            Text("Search text count is \(searchTextBinding.wrappedValue.count). Searching? \(searchBinding.wrappedValue ? "True" : "False")")

            ManufacturerEntryView(bike: bikeBinding,
                                  manufacturerSearchText: searchTextBinding,
                                  searching: searchBinding)
            .environment(client)
            .modelContainer(mockContainer)
            .modelContainer(for: Bike.self,
                            inMemory: true,
                            isAutosaveEnabled: false)
        }
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
