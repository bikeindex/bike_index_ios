//
//  AddBikeView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData

struct AddBikeView: View {

    // TODO: 1) Replace @State variables with writing modifications to an in-memory/non-autosave Bike model, 2) write the model to the API, 3) then persist it locally
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    // MARK: Shadow State

    // Shadow the serial number, manufacturer, and model to update the UI without unwrapping optionals
    @State var missingSerial = true
    @State var manufacturerSearchText = ""
    @State var manufacturerSearchActive = true
    @State var frameModel = ""

    /* Shadow the Bike.frameColors selection with local state to bridge the gap between Binding<FrameColor>
     * Picker(selection:) changes and updating the Bike [FrameColor] array.
     */
    @State var colorPrimary: FrameColor = .black
    @State var colorSecondary: FrameColor = .black
    @State var colorTertiary: FrameColor = .black

    /// Shadow over Bike cycleType in case there is a non-default value
    @State var traditionalBicycle = true
    /// Shadow over the User.email in case there are local changes
    @State var ownerEmail: String = ""

    // MARK: Authoritative State

    /// Primary model to mutate and persist
    @State var bike = Bike()
    /// Access the known users to perform autocomplete on the owner's email
    @Query var authenticatedUsers: [AuthenticatedUser]

    /// Required fields include
    /// 1. serialNumber not empty || missingSerialNumber == true
    /// 2. manufacturer not empty
    /// 3. Primary frame color not empty
    /// 4. owner email
    /// Source: attempt to register on the web with any string for the serial number
    /* TODO: revisit this **AFTER** replacing @State with an in-memory Bike model to let the model perform form validation
    private var requiredFieldsNotMet: Binding<Bool> {
        Binding {
            let passedSerial = !serialNumber.isEmpty || missingSerialNumber
            let passedManufacturer = !manufacturer.isEmpty
            // let passedFrameColor = colorPrimary -- Should we allow empty values in the color?
            // let ownerEmail = client. // TODO: Need to fetch account info, persist it, and provide it here
            return !(passedSerial && passedManufacturer)
        } set: { _ in
            // this is a one-way binding
        }
    }
     */

    var body: some View {
        NavigationView {
            Form {
                Section {
                    let safeSerial = Binding {
                        bike.serial ?? ""
                    } set: { newValue in
                        bike.serial = newValue
                        if let serial = bike.serial, !serial.isEmpty {
                            missingSerial = false
                        }
                    }

                    TextField(text: safeSerial) {
                        if missingSerial {
                            Text("Unknown — or provide a number")
                        } else {
                            Text("Required — or mark as missing")
                        }
                    }
                    .textInputAutocapitalization(.characters)
                    Toggle("Missing Serial Number", isOn: $missingSerial)
                        .onChange(of: missingSerial) { oldValue, newValue in
                            if oldValue != newValue, newValue == true {
                                bike.serial = nil
                            }
                        }
                } header: {
                    Text("Serial Number")
                } footer: {
                    Text("Every bike has a unique serial number, it's how they are identified. To learn more or see some examples, go to [our serial page](\(client.configuration.host)/serials).")
                }

                if traditionalBicycle {
                    Section {
                        Toggle("Traditional bicycle", isOn: $traditionalBicycle)
                    } footer: {
                        Text("Two wheels, one seat, no motor")
                    }
                } else {
                    Section {
                        Picker("This is a: ", selection: $bike.typeOfCycle) {
                            ForEach(BicycleType.allCases) { type in
                                Text(type.name)
                            }
                        }
                        // electric is not applicable for trail-behind
                        // electric is always off for scooter/skateboard
                        // electric is always active for e-scooter, personal mobility
                        Toggle("⚡️ Electric (motorized)", isOn: .constant(false))
                        // if electric { // not applicable for stroller/wheelchair/e-scooter/personal-mobility
                        Toggle("Throttle", isOn: .constant(false))
                        Toggle("Pedal Assist", isOn: .constant(false))
                        // }
                    } header: {
                        Text("Bicycle Type")
                    } footer: {
                        EmptyView()
                    }
                }

                Section {
                    ManufacturerEntryView(bike: $bike,
                                          manufacturerSearchText: $manufacturerSearchText,
                                          searching: $manufacturerSearchActive)
                        .environment(client)
                        .modelContext(modelContext)
                } header: {
                    Text("Manufacturer")
                } footer: {
                    Text("Select 'Other' if manufacturer doesn't show up when entered")
                }

                Section {
                    Picker("Model Year", selection: $bike.year) {
                        Text("Unknown year").tag(nil as Int?)
                        ForEach(Bike.Constants.displayableYearRange.reversed(), id: \.self) { year in
                            Text(year.description).tag(year as Int?)
                        }
                    }
                    .pickerStyle(.automatic)
                } header: {
                    Text("Year of manufacturing")
                } footer: {
                    Text("Select 'Unknown Year' if you don't know what year your bike was manufactured")
                }

                Section {
                    TextField(text: $frameModel) {
                        Text("Frame model")
                    }
                }

                Section {
                    Picker("Primary Frame Color", selection: $colorPrimary) {
                        ForEach(FrameColor.allCases) { option in
                            Text(option.displayValue)
                        }
                    }
                    .onChange(of: colorPrimary, { oldValue, newValue in
                        bike.frameColors.primary = newValue
                    })
                    .pickerStyle(.menu)

                    if $bike.frameColors.count == 1 {
                        Button("Add secondary color") {
                            bike.addFrameColor()
                        }
                    }
                    if $bike.frameColors.count >= 2 {
                        Picker("Secondary Frame Color", selection: $colorSecondary) {
                            ForEach(FrameColor.allCases) { option in
                                Text(option.displayValue)
                            }
                        }
                        .onChange(of: colorSecondary, { oldValue, newValue in
                            bike.frameColors.secondary = newValue
                        })
                        .pickerStyle(.menu)
                    }
                    if $bike.frameColors.count == 2 {
                        Button("Remove secondary color") {
                            bike.removeFrameColor()
                            colorSecondary = FrameColor.defaultColor
                        }
                        Button("Add tertiary color") {
                            bike.addFrameColor()
                        }
                    }
                    if $bike.frameColors.count == 3 {
                        Picker("Tertiary Frame Color", selection: $colorTertiary) {
                            ForEach(FrameColor.allCases) { option in
                                Text(option.displayValue)
                            }
                        }
                        .onChange(of: colorTertiary, { oldValue, newValue in
                            bike.frameColors.tertiary = newValue
                        })
                        .pickerStyle(.menu)
                        Button("Remove tertiary color") {
                            bike.removeFrameColor()
                            colorTertiary = FrameColor.defaultColor
                        }
                    }

                } header: {
                    Text("What color is the bike?")
                } footer: {
                    Text("The color of the frame and fork—not the wheels, cranks, or anything else. You can put a more detailed description in paint description (once you've registered), this is to get a general color to make searching easier")
                }

                Section(header: Text("Owner Email")) {
                    TextField(text: $ownerEmail) {
                        Text("Who should be contacted?")
                    }
                }

                Section {
                    Button {
                        registerBike()
                    } label: {
                        Text("Register")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            }
        }
        .navigationTitle("Enter Bike Details")
        .onAppear {
            if let user = authenticatedUsers.first?.user {
                ownerEmail = user.email
            }
        }
    }

    /// Write the Bike model to the local storage and mark it pending/in-progress
    /// Write the Bike model to the API client
    /// Mark the local model as synchronized
    /// Update the UI
    private func registerBike() {
        // https://developer.apple.com/documentation/swiftdata/adding-and-editing-persistent-data-in-your-app
    }
}

#Preview {
    do {
        let client = try Client()
        return AddBikeView()
            .environment(client)
            .modelContainer(for: User.self,
                            inMemory: true,
                            isAutosaveEnabled: false)
            .modelContainer(for: Bike.self,
                            inMemory: true,
                            isAutosaveEnabled: false)
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
