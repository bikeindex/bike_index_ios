//
//  ManufacturerEntryView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftData
import SwiftUI

struct ManufacturerEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    @FocusState.Binding var focus: RegisterBikeView.Field?

    @Binding var bike: Bike
    /// Stores temporary search text input.
    /// Later, if this is matched to a known manufacturer the form can proceed.
    @Binding var manufacturerSearchText: String
    @Binding var valid: Bool

    @Query var manufacturers: [AutocompleteManufacturer]

    init(
        bike: Binding<Bike>,
        manufacturerSearchText: Binding<String>,
        state: FocusState<RegisterBikeView.Field?>.Binding,
        valid: Binding<Bool>
    ) {
        _bike = bike
        _manufacturerSearchText = manufacturerSearchText
        _focus = state
        _valid = valid
        let searchTerm = manufacturerSearchText.wrappedValue

        let predicate = #Predicate<AutocompleteManufacturer> { model in
            model.text.contains(searchTerm)
        }

        var descriptor = FetchDescriptor<AutocompleteManufacturer>(predicate: predicate)
        descriptor.fetchLimit = 10

        _manufacturers = Query(descriptor)
    }

    var body: some View {
        let _ = Self._printChanges()
        TextField(
            "Search for manufacturer",
            text: $manufacturerSearchText
        )
        .foregroundStyle(valid ? .green : .secondary)  // BUG: this foreground style fails to update *after*
        .autocorrectionDisabled()
        .accessibilityIdentifier("manufacturerSearchTextField")
        .focused($focus, equals: .manufacturerText)
        .onChange(of: manufacturerSearchText) { oldQuery, newQuery in
            focus = .manufacturerText

            guard !newQuery.isEmpty else {
                bike.manufacturerName = ""
                return
            }

            // Next step: run .task to fetch query from the network API
            valid = false

            Task {
                print("ManufacturerEntryView task with query \(manufacturerSearchText)")
                let fetch_manufacturer = await client.api.get(
                    Autocomplete.manufacturer(query: manufacturerSearchText))
                switch fetch_manufacturer {
                case .success(let success):
                    guard
                        let autocompleteResponse = success
                            as? AutocompleteManufacturerContainerResponse
                    else {
                        Logger.views.debug(
                            "ManufacturerEntryView search failed to parse response from \(String(reflecting: success), privacy: .public)"
                        )
                        return
                    }

                    do {
                        for manufacturer in autocompleteResponse.matches {
                            modelContext.insert(manufacturer.modelInstance())
                        }
                        try? modelContext.save()
                    }

                    Logger.views.debug(
                        "ManufacturerEntryView received response \(String(describing: autocompleteResponse), privacy: .public)"
                    )

                case .failure(let failure):
                    Logger.views.error(
                        "ManufacturerEntryView search failed with \(String(reflecting: failure), privacy: .public)"
                    )
                }
            }
        }
        .onSubmit {
            focus = focus?.next()
        }
        if manufacturers.count == 1 && manufacturerSearchText == manufacturers.first?.text {
            /// After the user taps a selection, stop displaying the suggestions list
            /* EmptyView() */
            Text("Debug: field=\(String(describing: focus)), manufacturers.count=\(manufacturers.count), focus manf? \(focus == .manufacturerText)")
        } else if !manufacturerSearchText.isEmpty, manufacturers.count > 0,
            focus == .manufacturerText
        {
            Text("List of manufacturers, focus is manufacturer? \(focus == .manufacturerText)")
            List {
                ForEach(manufacturers) { manufacturer in
                    Button(manufacturer.text) {
                        bike.manufacturerName = manufacturer.text
                        manufacturerSearchText = manufacturer.text
                        focus = focus?.next()
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding([.leading, .trailing], 8)
        } else if manufacturers.count > 0 {
            Text("Debug: field=\(String(describing: focus)), manufacturers.count=\(manufacturers.count), focus manufacturer? \(focus == .manufacturerText)")

            Button("Other") {
                bike.manufacturerName = "Other"
                manufacturerSearchText = "Other"
                focus = focus?.next()
            }
            .foregroundStyle(.primary)
        }
    }
}

/// NOTE: These bindings are not working correctly
#Preview {
    @Previewable @State var previewBike: Bike = Bike()
    @Previewable @State var searchText = ""
    @Previewable @FocusState var focusState: RegisterBikeView.Field?
    @Previewable @State var valid = false

    let container = try! ModelContainer(
        for: AutocompleteManufacturer.self, Bike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    VStack {
        Text(
            "Search text count is \(searchText.count). Searching? \(String(describing: focusState))"
        )

        ManufacturerEntryView(
            bike: $previewBike,
            manufacturerSearchText: $searchText,
            state: $focusState,
            valid: $valid
        )
        .environment(try! Client())
        .modelContainer(container)
        .onAppear {
            let mockAutocompleteManufacturers = [
                AutocompleteManufacturer(
                    text: "Aaaaaaaa", category: "", slug: "aaa", priority: 1, searchId: "aaa",
                    identifier: 1),
                AutocompleteManufacturer(
                    text: "Bbbbbbbb", category: "", slug: "bbb", priority: 1, searchId: "bbb",
                    identifier: 1),
                AutocompleteManufacturer(
                    text: "Cccccccc", category: "", slug: "ccc", priority: 1, searchId: "ccc",
                    identifier: 1),
            ]

            mockAutocompleteManufacturers.forEach { manufacturer in
                container.mainContext.insert(manufacturer)
            }

            try? container.mainContext.save()
        }

        Spacer()
    }
}
