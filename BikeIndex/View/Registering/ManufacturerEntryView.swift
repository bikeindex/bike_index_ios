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

    let debugID = UUID()

    @FocusState.Binding var focus: RegisterBikeView.Field?

    /// Stores temporary search text input.
    /// Later, if this is matched to a known manufacturer the form can proceed.
    @Binding var manufacturerSearchText: String
    /// Control display of the required field asterisk or validation checkmark.
    /// Provided by the parent because refreshes occur very often
    @Binding var valid: Bool

    /// Live search query results.
    @Query private var manufacturers: [AutocompleteManufacturer]

    var selectAction: (String) -> Void

    init(
        manufacturerSearchText: Binding<String>,
        state: FocusState<RegisterBikeView.Field?>.Binding,
        valid: Binding<Bool>,
        selectAction: @escaping (String) -> Void
    ) {
        self._manufacturerSearchText = manufacturerSearchText
        self._focus = state
        self._valid = valid
        self.selectAction = selectAction

        let searchTerm = manufacturerSearchText.wrappedValue
        let predicate = #Predicate<AutocompleteManufacturer> { model in
            model.text.contains(searchTerm)
        }
        var descriptor = FetchDescriptor<AutocompleteManufacturer>(predicate: predicate)
        descriptor.fetchLimit = 10
        self._manufacturers = Query(descriptor)
    }

    private var prompt: Text {
        Text("Search for manufacturer")
    }

    var body: some View {
        TextField(
            "Search for manufacturer",
            text: $manufacturerSearchText
        )
        /*
         // Well! assigning the foreground style on a TextField fails.
         // I found this question asking for the same effect:
         // https://stackoverflow.com/questions/56715398/swiftui-how-do-i-change-the-text-color-of-a-textfield
         // Tested on Xcode 16 / iOS 18, and Xcode 26 / iOS 26
         // For example, in contrast, changing the scale to flip the text works!
         .scaleEffect(CGSize(width: 1, height: valid ? 1 : -1))
         .foregroundStyle(valid ? .green : .secondary)
         */
        .autocorrectionDisabled()
        .accessibilityIdentifier("manufacturerSearchTextField")
        .focused($focus, equals: .manufacturerText)
        .onChange(of: manufacturerSearchText, initial: false) { oldQuery, newQuery in
            focus = .manufacturerText

            guard !newQuery.isEmpty else {
                return
            }

            if manufacturers.count == 1 {
                attemptSelectFirst()
                return
            }

            // Next step: run .task to fetch query from the network API
            Task {
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
            attemptSelectFirst()
        }
        if !manufacturerSearchText.isEmpty {
            if manufacturers.count == 1, let first = manufacturers.first?.text, first == manufacturerSearchText {
                EmptyView()
            } else if manufacturers.count > 0 {
                List {
                    ForEach(manufacturers) { manufacturer in
                        Button(manufacturer.text) {
                            select(result: manufacturer.text)
                        }
                    }
                }
                .foregroundStyle(.secondary)
                .padding([.leading, .trailing], 8)
            } else {
                Button("Other") {
                    select(result: "Other")
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    private func attemptSelectFirst() {
        if let firstManufacturer = manufacturers.first?.text, manufacturerSearchText == firstManufacturer {
            select(result: firstManufacturer)
        }
    }

    /// Select a provided Manufacturer name search result.
    /// Arbitrary string to accept "Other".
    /// - Parameter result: The name of the manufacturer that the user has selected.
    private func select(result: String) {
        manufacturerSearchText = result
        selectAction(result)
        focus = focus?.next()
    }
}

#Preview {
    @Previewable @State var previewBike: Bike = Bike()
    @Previewable @State var searchText = ""
    @Previewable @FocusState var focusState: RegisterBikeView.Field?
    let valid = Binding {
        !previewBike.manufacturerName.isEmpty &&
        previewBike.manufacturerName == searchText
    } set: { _ in }


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
            state: $focusState,
            valid: valid
        ) { manufacturerSelection in
            previewBike.manufacturerName = manufacturerSelection
        }
        .environment(try! Client())
        .modelContainer(container)

        Spacer()
    }
}
