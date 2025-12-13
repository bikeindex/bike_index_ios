//
//  RegisterBikeView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import OSLog
import PhotosUI
import SwiftData
import SwiftUI
import WebViewKit

struct RegisterBikeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) var client
    @Environment(\.layoutDirection) var layoutDirection

    // MARK:  UI State

    /// Used for serial\_page link
    @State var showSerialsPage = false
    @Binding var path: NavigationPath
    /// Change behavior depending if this is your own bike or stolen, etc
    @State var mode: RegisterMode
    /// Focus state
    @FocusState var focus: Field?

    /// Access the known users to perform autocomplete on the owner's email
    @Query var authenticatedUsers: [AuthenticatedUser]

    // MARK: Validation State

    @State var viewModel: ViewModel

    init(path: Binding<NavigationPath>, mode: RegisterMode, viewModel: ViewModel? = nil) {
        self._path = path
        self.mode = mode
        if let viewModel {
            assert(
                viewModel.mode == mode,
                "RegisterBikeView and its view model _must_ have consistent modes.")
            self.viewModel = viewModel
        } else {
            self.viewModel = .init(mode: mode)
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            Form {
                #if DEBUG
                Text("Debug build: BikeRegistrations will be automatically deleted.")
                #endif

                if mode == .myStolenBike {
                    StolenBikeInfoSectionView()
                }

                // MARK: Photo
                // Disabled until properly tested
                Section {
                    switch viewModel.imageState {
                    case .success(let image):
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 16))
                            .overlay {
                                deleteButton
                            }
                    case .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity, idealHeight: 200)
                    case .empty:
                        CameraButton(photo: $viewModel.cameraPhoto) {
                            Label("Take Photo", systemImage: "camera")
                        }
                        .padding(.leading, 2)

                        PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images) {
                            Label("Choose Photo", systemImage: "photo.on.rectangle")
                        }
                        .padding(.leading, 2)
                    case .failure(let error):
                        Color.gray
                            .frame(height: 200)
                            .clipShape(.rect(cornerRadius: 16))
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.yellow)
                                    Text(error.localizedDescription)
                                        .foregroundStyle(.white)
                                        .fontWeight(.medium)
                                }
                                .padding()
                            }
                            .overlay {
                                deleteButton
                            }
                    }
                } header: {
                    Text("Photo")
                }

                // MARK: Serial number
                Section {
                    let safeSerial = Binding(
                        get: {
                            $viewModel.bike.serial.wrappedValue ?? ""
                        },
                        set: { newValue in
                            viewModel.bike.serial = newValue
                            if let serial = viewModel.bike.serial, !serial.isEmpty {
                                viewModel.missingSerial = false
                            }
                        })

                    TextField(text: safeSerial) {
                        if viewModel.missingSerial {
                            Text("Unknown — or provide a number")
                        } else {
                            Text("Required — or mark as missing")
                        }
                    }
                    .textInputAutocapitalization(.characters)
                    .focused($focus, equals: .serialNumberText)

                    HStack {
                        CameraTextCaptureButton(text: safeSerial)
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }

                    Toggle("Missing Serial Number", isOn: $viewModel.missingSerial)
                        .onChange(of: viewModel.missingSerial) { oldValue, newValue in
                            if oldValue != newValue, newValue == true {
                                viewModel.bike.serial = nil
                            }
                        }
                } header: {
                    RequiredField(
                        valid: viewModel.isSerialNumberValid,
                        label: "Serial Number")
                } footer: {
                    TextLink(base: client.configuration.host, link: .serials)
                        .environment(
                            \.openURL,
                            OpenURLAction { URL in
                                showSerialsPage = true
                                return .handled
                            }
                        )
                        .id(Field.serialNumberText)  // scroll target
                }

                // MARK: Bike type and propulsion
                BicycleTypeSelectionView(
                    bike: $viewModel.bike,
                    traditionalBicycle: $viewModel.traditionalBicycle,
                    propulsion: $viewModel.propulsion)

                // MARK: Manufacturer
                Section {
                    let readOnlyManufacturerValidity = Binding {
                        viewModel.isManufacturerValid
                    } set: { _ in
                    }

                    // Assigns `.focused($focus, equals: .manufacturerText)`
                    ManufacturerEntryView(
                        manufacturerSearchText: $viewModel.manufacturerSearchText,
                        state: $focus,
                        valid: readOnlyManufacturerValidity
                    ) { manufacturerSelection in
                        viewModel.bike.manufacturerName = manufacturerSelection
                    }
                    .environment(client)
                    .modelContext(modelContext)
                } header: {
                    RequiredField(
                        valid: viewModel.isManufacturerValid,
                        label: "Manufacturer")
                } footer: {
                    Text("Select 'Other' if manufacturer doesn't show up when entered")
                }

                // MARK: Year
                Section {
                    Picker("Model Year", selection: $viewModel.bike.year) {
                        Text("Unknown year").tag(nil as Int?)
                        ForEach(Bike.Constants.displayableYearRange.reversed(), id: \.self) {
                            year in
                            Text(year.description).tag(year as Int?)
                        }
                    }
                    .pickerStyle(.automatic)
                } header: {
                    Text("Year of manufacturing")
                } footer: {
                    Text(
                        "Select 'Unknown Year' if you don't know what year your bike was manufactured"
                    )
                }

                // MARK: Frame
                Section {
                    TextField(text: $viewModel.frameModel) {
                        Text("Frame model")
                    }
                    .focused($focus, equals: .frame)
                    .id(Field.frame)
                }

                // MARK: Frame colors
                Section {
                    Picker(selection: $viewModel.colorPrimary) {
                        ForEach(FrameColor.allCases) { option in
                            Text(option.displayValue)
                        }
                    } label: {
                        HStack {
                            Text("Primary Frame Color")
                            Chip(color: viewModel.colorPrimary)
                                .style(.circle)
                        }
                    }
                    // SwiftUI.Picker does not seem to support FocusState on iOS
                    // .focused($focus, equals: .primaryFrameColor)
                    .onChange(
                        of: viewModel.colorPrimary,
                        { _, newValue in
                            viewModel.bike.frameColorPrimary = newValue
                            focus = focus?.next()
                        }
                    )
                    .pickerStyle(.menu)

                    if viewModel.bike.frameColors.count == 1 {
                        Button("Add secondary color") {
                            viewModel.bike.frameColorSecondary = .black
                        }
                    }
                    if viewModel.bike.frameColors.count >= 2 {
                        Picker(selection: $viewModel.colorSecondary) {
                            ForEach(FrameColor.allCases) { option in
                                Text(option.displayValue)
                            }
                        } label: {
                            HStack {
                                Text("Secondary Frame Color")
                                Chip(color: viewModel.colorSecondary)
                                    .style(.circle)
                            }
                        }
                        .onChange(
                            of: viewModel.colorSecondary,
                            { oldValue, newValue in
                                viewModel.bike.frameColorSecondary = newValue
                            }
                        )
                        .pickerStyle(.menu)
                    }
                    if viewModel.bike.frameColors.count == 2 {
                        Button("Remove secondary color") {
                            viewModel.bike.frameColorSecondary = nil
                            viewModel.colorSecondary = FrameColor.defaultColor
                        }
                        Button("Add tertiary color") {
                            viewModel.bike.frameColorTertiary = .black
                        }
                    }
                    if viewModel.bike.frameColors.count == 3 {
                        Picker(selection: $viewModel.colorTertiary) {
                            ForEach(FrameColor.allCases) { option in
                                Text(option.displayValue)
                            }
                        } label: {
                            HStack {
                                Text("Tertiary Frame Color")
                                Chip(color: viewModel.colorTertiary)
                                    .style(.circle)
                            }
                        }
                        .onChange(
                            of: viewModel.colorTertiary,
                            { oldValue, newValue in
                                viewModel.bike.frameColorTertiary = newValue
                            }
                        )
                        .pickerStyle(.menu)
                        Button("Remove tertiary color") {
                            viewModel.bike.frameColorTertiary = nil
                            viewModel.colorTertiary = FrameColor.defaultColor
                        }
                    }

                } header: {
                    Text("What color is the bike?")
                } footer: {
                    Text(
                        "The color of the frame and fork—not the wheels, cranks, or anything else. You can put a more detailed description in paint description (once you've registered), this is to get a general color to make searching easier"
                    )
                    .id(Field.frame)
                }

                // MARK: - Mode-specific fields
                if mode == .myStolenBike {
                    StolenRecordEntryView(
                        record: $viewModel.stolenRecord,
                        focus: $focus
                    )
                }

                // NOTE: Consider adding ImpoundedRecordEntryView in the future

                // MARK: -

                // MARK: Email
                Section {
                    HStack {
                        TextField(text: $viewModel.ownerEmail) {
                            if mode == .myOwnBike {
                                Text("Who owns this bike?")
                            } else {
                                Text("Who is responsible for this registration?")
                            }
                        }
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .focused($focus, equals: .ownerEmailText)

                        Button("Clear", systemImage: clearImage) {
                            viewModel.ownerEmail = ""
                        }
                        .labelStyle(.iconOnly)
                        // https://www.hackingwithswift.com/forums/swiftui/buttons-in-a-form-section/6175/6176
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(viewModel.ownerEmail.isEmpty)
                    }
                    .id(Field.ownerEmailText)
                } header: {
                    RequiredField(
                        valid: viewModel.isOwnerValid,
                        label: "Owner Email")
                }

                // MARK: Save
                Section {
                    Button {
                        Task {
                            await viewModel.registerBike(
                                mode: mode,
                                path: $path,
                                client: client,
                                modelContext: modelContext)
                        }
                    } label: {
                        Text("Register")
                    }
                    .focused($focus, equals: .registerButton)
                    .alert(
                        viewModel.output.title,
                        isPresented: $viewModel.output.show,
                        actions: {
                            Button("Okay") {
                                viewModel.output.actions()
                            }
                        },
                        message: {
                            Text(viewModel.output.message)
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(Field.registerButton)
                } footer: {
                    if !client.userCanRegisterBikes {
                        Text(
                            "Oh no, your authorization doesn't include the ability to register a bike!"
                        )
                    }
                }
                .disabled(!client.userCanRegisterBikes && viewModel.requiredFieldsNotMet)
            }
            .onChange(
                of: focus, initial: false,
                { _, newValue in
                    scrollProxy.scrollTo(newValue)
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    #if DEBUG
                    Menu("Scroll to") {
                        ForEach(Field.allCases) { field in
                            Button(field.title) {
                                scrollProxy.scrollTo(field)
                                focus = field
                            }
                        }
                    }
                    #endif
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if client.userCanRegisterBikes && !viewModel.requiredFieldsNotMet {
                        Button {
                            focus = .registerButton
                            scrollProxy.scrollTo(Field.registerButton)
                        } label: {
                            Text(viewModel.remainingRequiredFields)
                        }
                    } else {
                        Text(viewModel.remainingRequiredFields)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(mode.navigationBarDisplayMode)
        .navigationTitle(mode.title)
        .scrollDismissesKeyboard(.interactively)
        .onSubmit {
            focus = focus?.next()
        }
        .onAppear {
            if let user = authenticatedUsers.first?.user {
                viewModel.ownerEmail = user.email
            } else {
                Logger.views.info(
                    "Failed to find authenticated users with email, skipping association of ownerEmail. Authenticated users has count \(authenticatedUsers.count)"
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

    var clearImage: String {
        switch layoutDirection {
        case .leftToRight:
            "delete.left"
        case .rightToLeft:
            "delete.right"
        @unknown default:
            "delete.left"
        }
    }

    var ownerContactStackDirection: Alignment {
        switch layoutDirection {
        case .leftToRight:
            .trailing
        case .rightToLeft:
            .leading
        @unknown default:
            .trailing
        }
    }

    var deleteButton: some View {
        Button {
            viewModel.imageState = .empty
        } label: {
            Image(systemName: "xmark.circle.fill")
                .imageScale(.large)
                .background {
                    Circle()
                        .foregroundStyle(.primary)
                }
                .padding(8)
                .foregroundStyle(.white, .separator)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

}

extension RegisterBikeView {
    /// Registration field for FocusState. Not all fields are required.
    /// Used for "return ⏎" key to navigate to the next field.
    /// Only enumerates text fields because iOS FocusState seems to be incompatible with SwiftUI.Picker.
    enum Field: Int, Identifiable, Hashable, CaseIterable {
        case serialNumberText
        case manufacturerText
        /// Frame is not a required field, but nice to navigate to
        case frame
        /// Phone Number is only shown/required for stolen bikes
        case phoneNumber
        case addressOrIntersection
        /// City is only shown/required for stolen bikes
        case city
        case postalCode
        case ownerEmailText
        case registerButton

        var id: Self { self }

        func next() -> Field? {
            let start = self.rawValue
            let next = Field(rawValue: start + 1)
            return next
        }

        #if DEBUG
        /// Used for debug-only Scroll To menu
        var title: String {
            switch self {
            case .serialNumberText:
                "Serial Number"
            case .manufacturerText:
                "Manufacturer"
            case .frame:
                "Frame"
            case .phoneNumber:
                "Phone Number"
            case .addressOrIntersection:
                "Address or Intersection"
            case .city:
                "City"
            case .postalCode:
                "Postal Code"
            case .ownerEmailText:
                "Owner Email"
            case .registerButton:
                "Register Button"
            }
        }
        #endif
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
    let mode = RegisterMode.myOwnBike
    let viewModel = RegisterBikeView.ViewModel(mode: mode)

    let previewContent = RegisterBikeView(
        path: .constant(NavigationPath()),
        mode: mode,
        viewModel: viewModel
    )
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

    let mode = RegisterMode.myStolenBike
    let viewModel = RegisterBikeView.ViewModel(mode: mode)

    let previewContent = RegisterBikeView(
        path: .constant(NavigationPath()),
        mode: mode,
        viewModel: viewModel
    )
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
