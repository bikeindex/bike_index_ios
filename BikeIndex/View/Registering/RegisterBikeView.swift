//
//  RegisterBikeView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI
import SwiftData
import OSLog
import WebViewKit

/// NOTE: Adopt @Focus State https://developer.apple.com/documentation/swiftui/focusstate
/// NOTE: Possibly add organization selection
struct RegisterBikeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client

    // MARK: Shadow State

    // Shadow the serial number, manufacturer, and model to update the UI without unwrapping optionals
    @State var missingSerial = false
    @State var manufacturerSearchText = ""
    @State var manufacturerSearchActive = false
    @State var frameModel = ""

    /* Shadow the Bike.frameColors selection with local state to bridge the gap between Binding<FrameColor>
     * Picker(selection:) changes and updating the Bike [FrameColor] array.
     */
    @State var colorPrimary = FrameColor.defaultColor
    @State var colorSecondary = FrameColor.defaultColor
    @State var colorTertiary = FrameColor.defaultColor

    /// Shadow over Bike cycleType in case there is a non-default value
    @State var traditionalBicycle = true
    /// Shadow over the User.email in case there are local changes
    @State var ownerEmail: String = ""

    // MARK: Validation State

    @State var validationModel = AddBikeOutput()

    // MARK:  UI State

    /// Used for serial\_page link
    @State var link: URL?

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
    private var requiredFieldsNotMet: Bool {
        let passedSerial = missingSerial || (!(bike.serial?.isEmpty ?? true))
        let passedManufacturer = !bike.manufacturerName.isEmpty
        let passedEmail = !ownerEmail.isEmpty
        return !(passedSerial && passedManufacturer && passedEmail)
    }

    var body: some View {
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
                TextLink(base: client.configuration.host, link: .serials)
                    .environment(\.openURL, OpenURLAction { URL in
                        link = URL
                        return .handled
                    })
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
                    bike.frameColorPrimary = newValue
                })
                .pickerStyle(.menu)

                if bike.frameColors.count == 1 {
                    Button("Add secondary color") {
                        bike.frameColorSecondary = .black
                    }
                }
                if bike.frameColors.count >= 2 {
                    Picker("Secondary Frame Color", selection: $colorSecondary) {
                        ForEach(FrameColor.allCases) { option in
                            Text(option.displayValue)
                        }
                    }
                    .onChange(of: colorSecondary, { oldValue, newValue in
                        bike.frameColorSecondary = newValue
                    })
                    .pickerStyle(.menu)
                }
                if bike.frameColors.count == 2 {
                    Button("Remove secondary color") {
                        bike.frameColorSecondary = nil
                        colorSecondary = FrameColor.defaultColor
                    }
                    Button("Add tertiary color") {
                        bike.frameColorTertiary = .black
                    }
                }
                if bike.frameColors.count == 3 {
                    Picker("Tertiary Frame Color", selection: $colorTertiary) {
                        ForEach(FrameColor.allCases) { option in
                            Text(option.displayValue)
                        }
                    }
                    .onChange(of: colorTertiary, { oldValue, newValue in
                        bike.frameColorTertiary = newValue
                    })
                    .pickerStyle(.menu)
                    Button("Remove tertiary color") {
                        bike.frameColorTertiary = nil
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
                .textInputAutocapitalization(.never)
            }

            Section {
                Button {
                    Task { await registerBike() }
                } label: {
                    Text("Register")
                }
                .alert(validationModel.title,
                       isPresented: $validationModel.show,
                       actions: {
                    Button("Okay") {
                        validationModel.actions()
                    }
                }, message: {
                    Text(validationModel.message)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } footer: {
                if !client.userCanRegisterBikes {
                    Text("Oh no, your authorization doesn't include the ability to register a bike!")
                }
            }
            .disabled(client.userCanRegisterBikes && requiredFieldsNotMet)
        }
        .navigationTitle("Enter Bike Details")
        .onAppear {
            if let user = authenticatedUsers.first?.user {
                ownerEmail = user.email
            }
        }
        .navigationDestination(item: $link) { url in
            WebView(url: url)
        }
    }

    /// Marshall the Bike model to a Postable intermediary, write that intermediary to the API client and discard Bike model
    /// Receive the result and persist the server's model
    /// Update the UI
    private func registerBike() async {
        Logger.model.debug("\(#function) Registering bike w/ serial \(String(describing: bike.serial))")
        Logger.model.debug("\(#function) Registering bike w/ manufacturerName \(String(describing: bike.manufacturerName))")
        Logger.model.debug("\(#function) Registering bike w/ frameColors \(String(describing: bike.frameColors))")
        Logger.model.debug("\(#function) Registering w/ owner email \(String(describing: ownerEmail))")

        let bikeRegistration = BikeRegistration(bike: bike,
                                                stolen: nil,
                                                ownerEmail: ownerEmail)
        let endpoint = Bikes.postBikes(form: bikeRegistration)
        let response = await client.api.post(endpoint)
        switch response {
        case .success(let success):
            guard let registrationResponseSource = success as? SingleBikeResponseContainer else {
                Logger.views.error("Failed to parse bike registtration successful response from \(String(reflecting: success))")
                return
            }

            let bikeModel = registrationResponseSource.bike.modelInstance()
            modelContext.insert(bikeModel)
            self.validationModel = AddBikeOutput(show: true, actions: {
                dismiss()
            }, message: "", title: "Success!")

        case .failure(let failure):
            Logger.views.error("Failed to register bike with model \(String(reflecting: bikeRegistration)), endpoint \(String(reflecting: endpoint))")
            Logger.views.error("Failed to register bike with failure \(String(reflecting: failure)), response \(String(reflecting: response))")

            self.validationModel = AddBikeOutput(show: true, actions: {

            }, message: LocalizedStringKey(failure.localizedDescription), title: "Registering bike failed")
        }
    }
}

#Preview {
    do {
        let bike = Bike()
        let client = try Client()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
                                           configurations: config)

        let user = User(username: "previewUser", name: "Preview User", email: "preview@bikeindex.org", additionalEmails: [], createdAt: Date(), image: nil, twitter: nil)

        let auth = AuthenticatedUser(identifier: "1")
        auth.user = user
        container.mainContext.insert(auth)

        return NavigationStack {
            RegisterBikeView(bike: bike)
                .environment(client)
                .modelContainer(container)
        }
    } catch let error {
        return Text("Failed to load preview \(error.localizedDescription)")
    }
}
