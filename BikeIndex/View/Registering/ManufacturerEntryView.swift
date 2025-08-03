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

    /// Stores temporary search text input.
    /// Later, if this is matched to a known manufacturer the form can proceed.
    @Binding var manufacturerSearchText: String
    /// Inform the parent view whenever a selection is complete or incomplete (still typing, not found in manufacturers list, etc).
    @Binding var isSelectionComplete: Bool
    /// Control display of the required field asterisk or validation checkmark.
    /// Provided by the parent because refreshes occur very often
    var valid: Bool

    /// Live search query results.
    @Query private var manufacturers: [AutocompleteManufacturer]

    init(
        manufacturerSearchText: Binding<String>,
        isSelectionComplete: Binding<Bool>,
        state: FocusState<RegisterBikeView.Field?>.Binding,
        valid: Bool
    ) {

        self._manufacturerSearchText = manufacturerSearchText
        self._isSelectionComplete = isSelectionComplete
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
                return
            }

            // Prevent updating the UI after a selection has been made.
            guard isSelectionComplete == false else {
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

                    isSelectionComplete = false

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
            selectFirst()
        }
        .onAppear {
            if manufacturers.count == 1 {
                selectFirst()
            }
        }
        if !manufacturerSearchText.isEmpty {
            if manufacturers.count > 0 {
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
            } else {
                Text("Debug: field=\(String(describing: focus)), manufacturers.count=\(manufacturers.count), focus manufacturer? \(focus == .manufacturerText)")

                Button("Other") {
                    select(result: "Other")
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private func selectFirst() {
        if let firstManufacturer = manufacturers.first?.text, manufacturerSearchText == firstManufacturer {
            select(result: firstManufacturer)
        }
    }

    /// Select a provided Manufacturer name search result.
    /// Arbitrary string to accept "Other".
    /// - Parameter result: The name of the manufacturer that the user has selected.
    private func select(result: String) {
        manufacturerSearchText = result
        isSelectionComplete = true
        focus = focus?.next()
    }
}

#Preview {
    @Previewable @State var previewBike: Bike = Bike()
    @Previewable @State var searchText = ""
    @Previewable @State var isSelectionComplete: Bool = false
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
            manufacturerSearchText: $searchText,
            isSelectionComplete: $isSelectionComplete,
            state: $focusState,
            valid: valid
        )
        .environment(try! Client())
        .modelContainer(container)

        Spacer()
    }
}
