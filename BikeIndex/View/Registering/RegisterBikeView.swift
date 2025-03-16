//
//  RegisterBikeView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import SwiftData
import SwiftUI
import WebViewKit

/// NOTE: Adopt @Focus State https://developer.apple.com/documentation/swiftui/focusstate
/// NOTE: Possibly add organization selection
struct RegisterBikeView: View {
    // @Environment(\.dismiss) private var dismiss // Can't use with NavigableWebView for serial or how-to-recover links
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client
    @Environment(\.dismiss) var dismiss

    // MARK: Shadow State

    // Shadow the serial number, manufacturer, and model to update the UI without unwrapping optionals
    @State var missingSerial = false
    @State var manufacturerSearchText = ""
    @FocusState var manufacturerSearchState: ManufacturerEntryView.EditState?
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
    @State var showSerialsPage = false

    // MARK: Authoritative State

    /// Change behavior depending if this is your own bike or stolen, etc
    @State var mode: RegisterMode

    /// Primary model to mutate and persist
    @State var bike = Bike()
    /// Sub-model for electric/throttle/pedal-assist behavior. Will be combined with BikeRegistration inside ``registerBike()`` function.
    @State var propulsion = BikeRegistration.Propulsion()
    @State var stolenRecord = StolenRecord(phone: "", city: "")
    /// Access the known users to perform autocomplete on the owner's email
    @Query var authenticatedUsers: [AuthenticatedUser]

    /// Required fields include
    /// 1. serialNumber not empty || missingSerialNumber == true
    /// 2. manufacturer not empty
    /// 3. Primary frame color not empty
    /// 4. owner email
    /// Source: attempt to register on the web with any string for the serial number
    private var requiredFieldsNotMet: Bool {
        // Serial is required, unless marked missing/unidentified
        // There's also made_without_Serial but that's a more complicated scenario
        let passedSerial = missingSerial || (!(bike.serial?.isEmpty ?? true))
        let passedManufacturer = !bike.manufacturerName.isEmpty
        // Email is required, unless the bike is abandoned/impounded
        let passedEmail = !ownerEmail.isEmpty
        return !(passedSerial && passedManufacturer && passedEmail)
    }

    var body: some View {
        Form {
            if mode == .myStolenBike {
                Section {
                    NavigationLink {
                        NavigableWebView(
                            constantLink: .stolenBikeFAQ,
                            host: client.configuration.host
                        )
                        .environment(client)
                    } label: {
                        Text("⚠️ How to get your stolen bike back")
                    }
                }

            }

            // MARK: Serial number
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

                HStack {
                    CameraCaptureButton(text: safeSerial)
                    Spacer()
                        .frame(maxWidth: .infinity)
                }

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
                    .environment(
                        \.openURL,
                        OpenURLAction { URL in
                            showSerialsPage = true
                            return .handled
                        })
            }

            // MARK: Bike type and propulsion
            BicycleTypeSelectionView(
                bike: $bike,
                traditionalBicycle: $traditionalBicycle,
                propulsion: $propulsion)

            // MARK: Manufacturer
            Section {
                ManufacturerEntryView(
                    bike: $bike,
                    manufacturerSearchText: $manufacturerSearchText,
                    state: $manufacturerSearchState
                )
                .environment(client)
                .modelContext(modelContext)
            } header: {
                Text("Manufacturer")
            } footer: {
                Text("Select 'Other' if manufacturer doesn't show up when entered")
            }

            // MARK: Year
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

            // MARK: Frame
            Section {
                TextField(text: $frameModel) {
                    Text("Frame model")
                }
            }

            // MARK: Frame colors
            Section {
                Picker("Primary Frame Color", selection: $colorPrimary) {
                    ForEach(FrameColor.allCases) { option in
                        Text(option.displayValue)
                    }
                }
                .onChange(
                    of: colorPrimary,
                    { oldValue, newValue in
                        bike.frameColorPrimary = newValue
                    }
                )
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
                    .onChange(
                        of: colorSecondary,
                        { oldValue, newValue in
                            bike.frameColorSecondary = newValue
                        }
                    )
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
                    .onChange(
                        of: colorTertiary,
                        { oldValue, newValue in
                            bike.frameColorTertiary = newValue
                        }
                    )
                    .pickerStyle(.menu)
                    Button("Remove tertiary color") {
                        bike.frameColorTertiary = nil
                        colorTertiary = FrameColor.defaultColor
                    }
                }

            } header: {
                Text("What color is the bike?")
            } footer: {
                Text(
                    "The color of the frame and fork—not the wheels, cranks, or anything else. You can put a more detailed description in paint description (once you've registered), this is to get a general color to make searching easier"
                )
            }

            // MARK: - Mode-special fields
            if mode == .myStolenBike {
                StolenRecordEntryView(record: $stolenRecord)
            }
            // NOTE: Consider adding ImpoundedRecordEntryView in the future
            // MARK: -

            // MARK: Email
            if mode == .myOwnBike || mode == .myStolenBike {
                Section(header: Text("Owner Email")) {
                    TextField(text: $ownerEmail) {
                        Text("Who should be contacted?")
                    }
                    .textInputAutocapitalization(.never)
                }
            }

            // MARK: Save
            Section {
                Button {
                    Task { await registerBike() }
                } label: {
                    Text("Register")
                }
                .alert(
                    validationModel.title,
                    isPresented: $validationModel.show,
                    actions: {
                        Button("Okay") {
                            validationModel.actions()
                        }
                    },
                    message: {
                        Text(validationModel.message)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } footer: {
                if !client.userCanRegisterBikes {
                    Text(
                        "Oh no, your authorization doesn't include the ability to register a bike!")
                }
            }
            .disabled(client.userCanRegisterBikes && requiredFieldsNotMet)
        }
        .navigationTitle(mode.title)
        .onAppear {
            if let user = authenticatedUsers.first?.user {
                ownerEmail = user.email
            } else {
                Logger.views.info(
                    "Failed to find authenticated users with email, skiping association of ownerEmail. Authenticated users has count \(authenticatedUsers.count)"
                )
            }
        }
        .navigationDestination(isPresented: $showSerialsPage) {
            NavigableWebView(
                constantLink: .serials,
                host: client.configuration.host
            )
            .environment(client)
        }
    }

    /// Marshall the Bike model to a Postable intermediary, write that intermediary to the API client and discard Bike model
    /// Receive the result and persist the server's model
    /// Update the UI
    private func registerBike() async {
        Logger.model.debug(
            "\(#function) Registering bike w/ serial \(String(describing: bike.serial))")
        Logger.model.debug(
            "\(#function) Registering bike w/ manufacturerName \(String(describing: bike.manufacturerName))"
        )
        Logger.model.debug(
            "\(#function) Registering bike w/ frameColors \(String(describing: bike.frameColors))")
        Logger.model.debug(
            "\(#function) Registering w/ owner email \(String(describing: ownerEmail))")

        let bikeRegistration = BikeRegistration(
            bike: bike,
            mode: mode,
            stolen: stolenRecord,
            propulsion: propulsion,
            ownerEmail: ownerEmail)
        let endpoint = Bikes.postBikes(form: bikeRegistration)
        let response = await client.api.post(endpoint)
        switch response {
        case .success(let success):
            guard let registrationResponseSource = success as? SingleBikeResponseContainer else {
                Logger.views.error(
                    "Failed to parse bike registtration successful response from \(String(reflecting: success))"
                )
                return
            }

            do {
                let bikeModel = registrationResponseSource.bike.modelInstance()
                modelContext.insert(bikeModel)

                try? modelContext.save()
                self.validationModel = AddBikeOutput(
                    show: true,
                    actions: {
                        /// Access dismiss directly.
                        /// If ``RegisterBikeView`` captures the Environment object in a var it will conflict with the
                        /// NavigableWebViews and cause an infinite loop. (I think that's the cause).
                        dismiss()
                    }, message: "", title: "Success!")
            }

        case .failure(let failure):
            Logger.views.error(
                "Failed to register bike with model \(String(reflecting: bikeRegistration)), endpoint \(String(reflecting: endpoint))"
            )
            Logger.views.error(
                "Failed to register bike with failure \(String(reflecting: failure)), response \(String(reflecting: response))"
            )

            self.validationModel = AddBikeOutput(
                show: true,
                actions: {

                }, message: LocalizedStringKey(failure.localizedDescription),
                title: "Registering bike failed")
        }
    }
}

// MARK: - Normal Mode Preview
#Preview("Normal Mode Preview") {
    let bike = Bike()
    let client = try! Client()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: config)

    let user = User(
        email: "preview@bikeindex.org", username: "previewUser", name: "Preview User",
        additionalEmails: [], createdAt: Date(), image: nil, twitter: nil, parent: nil,
        bikes: [bike])

    let auth = AuthenticatedUser(identifier: "1", bikes: [bike])

    let previewContent = RegisterBikeView(mode: .myOwnBike, bike: bike)
        .environment(client)
        .modelContainer(container)
        .onAppear {
            auth.user = user
            container.mainContext.insert(auth)
        }
    if ProcessInfo().isRunningPreviews {
        NavigationStack {
            previewContent
        }
    } else {
        previewContent
    }
}

// MARK: - Stolen Mode Preview
#Preview("Stolen Mode Preview") {
    let bike = Bike()
    let client = try! Client()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    let container = try! ModelContainer(
        for: AuthenticatedUser.self, User.self, Bike.self, AutocompleteManufacturer.self,
        configurations: config)

    let user = User(
        email: "preview@bikeindex.org", username: "previewUser", name: "Preview User",
        additionalEmails: [], createdAt: Date(), image: nil, twitter: nil, parent: nil,
        bikes: [bike])

    let auth = AuthenticatedUser(identifier: "1", bikes: [bike])

    let previewContent = RegisterBikeView(mode: .myStolenBike, bike: bike)
        .environment(client)
        .modelContainer(container)
        .onAppear {
            auth.user = user
            container.mainContext.insert(auth)
        }
    if ProcessInfo().isRunningPreviews {
        NavigationStack {
            previewContent
        }
    } else {
        previewContent
    }
}
