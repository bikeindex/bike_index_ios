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

    /// Update the manufacturer values of the pending Bike registration.
    @Binding var bikeManufacturer: String

    /// Stores temporary search text input.
    /// Later, if this is matched to a known manufacturer the form can proceed.
    @Binding var manufacturerSearchText: String
    /// Control display of the required field asterisk or validation checkmark.
    /// Provided by the parent because refreshes occur very oten
    var valid: Bool

    /// Live search query results.
    @Query private var manufacturers: [AutocompleteManufacturer]

    init(
        bikeManufacturer: Binding<String>,
        manufacturerSearchText: Binding<String>,
        state: FocusState<RegisterBikeView.Field?>.Binding,
        valid: Bool
    ) {
        print("Instantiated new ManufacturerEntryView based at \(Date()) -- with \(bikeManufacturer), search \(manufacturerSearchText), state \(String(describing: state.wrappedValue)), valid \(valid)")

        self._bikeManufacturer = bikeManufacturer
        self._manufacturerSearchText = manufacturerSearchText
        self._focus = state
        self.valid = valid

        let searchTerm = manufacturerSearchText.wrappedValue
        let predicate = #Predicate<AutocompleteManufacturer> { model in
            model.text.contains(searchTerm)
        }
        var descriptor = FetchDescriptor<AutocompleteManufacturer>(predicate: predicate)
        descriptor.fetchLimit = 10
        self._manufacturers = Query(descriptor)
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
                bikeManufacturer = ""
                return
            }

            // Next step: run .task to fetch query from the network API
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
        if manufacturers.count == 1,
            let first = manufacturers.first,
            manufacturerSearchText == first.text
        {
            /// After the user taps a selection, stop displaying the suggestions list
            EmptyView()
                .onAppear {
                    select(result: first.text)
                }
        } else if !manufacturerSearchText.isEmpty, manufacturers.count > 0,
            focus == .manufacturerText
        {
            Text("List of manufacturers, focus is manufacturer? \(focus == .manufacturerText)")
            List {
                ForEach(manufacturers) { manufacturer in
                    Button(manufacturer.text) {
                        select(result: manufacturer.text)
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding([.leading, .trailing], 8)
        } else if manufacturers.count > 0 {
            Text("Debug: field=\(String(describing: focus)), manufacturers.count=\(manufacturers.count), focus manufacturer? \(focus == .manufacturerText)")

            Button("Other") {
                select(result: "Other")
            }
            .foregroundStyle(.primary)
        }
    }

    /// Select a provided Manufacturer name search result.
    /// Arbitrary string to accept "Other".
    /// - Parameter result: The name of the manufacturer that the user has selected.
    private func select(result: String) {
        bikeManufacturer = result
        manufacturerSearchText = result
        focus = focus?.next()
    }
}

#Preview {
    @Previewable @State var previewBike: Bike = Bike()
    @Previewable @State var searchText = ""
    @Previewable @FocusState var focusState: RegisterBikeView.Field?
    var valid: Bool {
        !previewBike.manufacturerName.isEmpty &&
        previewBike.manufacturerName == searchText
    }

    let container = try! ModelContainer(
        for: AutocompleteManufacturer.self, Bike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    VStack {
        Text(
            "Search text count is \(searchText.count). Searching? \(String(describing: focusState))"
        )
        VStack(alignment: .leading) {
            Text("Stateful Bike manufacturer is \(previewBike.manufacturerName)")
            Text("Stateful search text is \(searchText)")
            Text("Stateful focus is \(String(describing: focusState))")
            Text("Stateful validation is \(valid)")
        }

        Divider()

        ManufacturerEntryView(
            bikeManufacturer: $previewBike.manufacturerName,
            manufacturerSearchText: $searchText,
            state: $focusState,
            valid: valid
        )
        .environment(try! Client())
        .modelContainer(container)

        Spacer()
    }
}
