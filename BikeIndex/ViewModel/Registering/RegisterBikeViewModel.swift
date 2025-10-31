//
//  RegisterBikeViewModel.swift
//  BikeIndex
//
//  Created by Jack on 8/9/25.
//

import Combine
import Foundation
import OSLog
import PhotosUI
import SwiftData
import SwiftUI

extension RegisterBikeView {
    @Observable @MainActor
    class ViewModel: ObservableObject {
        init(
            mode: RegisterMode, bike: Bike = Bike(),
            propulsion: BikeRegistration.Propulsion = BikeRegistration.Propulsion(),
            stolenRecord: StolenRecord = StolenRecord(phone: "", city: ""),
            output: AddBikeOutput = AddBikeOutput()
        ) {
            self.mode = mode
            self.bike = bike
            self.propulsion = propulsion
            self.stolenRecord = stolenRecord
            self.output = output
        }

        // MARK: Authoritative State
        var mode: RegisterMode

        /// Primary model to mutate and persist
        var bike = Bike()
        /// Sub-model for electric/throttle/pedal-assist behavior. Will be combined with BikeRegistration inside ``registerBike()`` function.
        var propulsion = BikeRegistration.Propulsion()
        /// Sub-model for stolen bikes.
        var stolenRecord = StolenRecord(phone: "", city: "")
        /// Track if any errors occurred when submitting this bike
        /// and report them back up to the UI
        var output = AddBikeOutput()

        // MARK: Shadow State
        // Shadow the serial number, manufacturer, and model to update the UI without unwrapping optionals
        var missingSerial = false
        /// Track the search field value for the manufacturer query _and_ value.
        var manufacturerSearchText = ""
        var frameModel = ""

        /// Shadow the Bike.frameColors selection with local state to bridge the gap between `Binding<FrameColor>`
        /// Picker(selection:) changes and updating the Bike [FrameColor] array.
        var colorPrimary = FrameColor.defaultColor
        /// Shadow the Bike.frameColors selection with local state to bridge the gap between `Binding<FrameColor>`
        /// Picker(selection:) changes and updating the Bike [FrameColor] array.
        var colorSecondary = FrameColor.defaultColor
        /// Shadow the Bike.frameColors selection with local state to bridge the gap between `Binding<FrameColor>`
        /// Picker(selection:) changes and updating the Bike [FrameColor] array.
        var colorTertiary = FrameColor.defaultColor

        /// Shadow over Bike cycleType in case there is a non-default value
        var traditionalBicycle = true
        /// Shadow over the User.email in case there are local changes
        var ownerEmail: String = ""

        var cameraPhoto: UIImage? = nil {
            didSet {
                if let cameraPhoto {
                    imageState = .success(cameraPhoto)
                }
            }
        }

        var photosPickerItem: PhotosPickerItem? = nil {
            didSet {
                if let photosPickerItem {
                    let progress = photosPickerItem.loadTransferable(type: UIImage.self) { result in
                        DispatchQueue.main.async { [weak self] in
                            switch result {
                            case .success(let image?):
                                self?.imageState = .success(image)
                            case .success(nil):
                                self?.imageState = .empty
                            case .failure(let error):
                                self?.imageState = .failure(error)
                            }
                        }
                    }
                    imageState = .loading(progress)
                }
            }
        }

        enum ImageState {
            case empty
            case loading(Progress)
            case success(UIImage)
            case failure(Error)
        }

        var imageState: ImageState = .empty

        /// Required fields include
        /// 1. serialNumber not empty || missingSerialNumber == true
        /// 2. manufacturer not empty
        /// 3. Primary frame color not empty
        /// 4. owner email
        /// Stolen bikes also include:
        /// 5. phone
        /// 6. city
        /// Source: attempt to register on the web with any string for the serial number
        var requiredFieldsNotMet: Bool {
            // Serial is required, unless marked missing/unidentified
            // There's also made_without_Serial but that's a more complicated scenario
            // Frame color is assigned by default
            // Email is required, unless the bike is abandoned/impounded
            if mode == .myOwnBike {
                !(isSerialNumberValid
                    && isManufacturerValid
                    && isOwnerValid)
            } else {
                !(isSerialNumberValid
                    && isManufacturerValid
                    && isOwnerValid
                    && stolenRecord.isPhoneValid
                    && stolenRecord.isCityValid)
            }
        }

        var isSerialNumberValid: Bool {
            missingSerial || (!(bike.serial?.isEmpty ?? true))
        }

        /// Validate that the manufacturer query text is appropriate to use for the bike.manufacturer name, in sync, and
        /// valid to proceed.
        var isManufacturerValid: Bool {
            !bike.manufacturerName.isEmpty
                && bike.manufacturerName == manufacturerSearchText
        }

        /// Frame color UI defaults to black and always has a valid value
        var isFrameColorValid: Bool { true }

        var isOwnerValid: Bool {
            !ownerEmail.isEmpty && validateEmail(ownerEmail)
        }

        /// Tell the user how many fields they need to fill out to be ready to register
        /// Frame color is the fourth required field! But it defaults to black because it's much easier to
        /// work with a SwiftUI.Picker that has a default.
        var remainingRequiredFields: String {
            if mode == .myOwnBike {
                let fields = [
                    isSerialNumberValid, isManufacturerValid, isFrameColorValid, isOwnerValid,
                ]
                let completedFields = fields.filter { $0 == true }.count
                let glyphs = [
                    1: "¼",
                    2: "²⁄₄",
                    3: "¾",
                    4: "✔︎",
                ]
                return glyphs[completedFields, default: ""]
            } else {
                let fields = [
                    isSerialNumberValid, isManufacturerValid, isFrameColorValid, isOwnerValid,
                    stolenRecord.isPhoneValid, stolenRecord.isCityValid,
                ]
                let completedFields = fields.filter { $0 == true }.count
                let glyphs = [
                    1: "⅙",
                    2: "²⁄₆",
                    3: "³⁄₆",
                    4: "⁴⁄₆",
                    5: "⅚",
                    6: "✔︎",
                ]
                return glyphs[completedFields, default: ""]
            }
        }

        func validateEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil)
                != nil
        }

//        func imageUploadCompletion(result: Result<Data, Error>) { result in
//            do {
//                switch result {
//                case .success(let data):
//                    guard let imageResponseContainer = try JSONDecoder().decode(endpoint.responseModel, from: data) as? ImageResponseContainer else {
//                        Logger.model.debug(
//                            "\(#function) Failed to decode image upload response after bike registration"
//                        )
//                        return
//                    }
//                    Logger.model.debug(
//                        "\(#function) Image upload successful in \(Date().timeIntervalSince(start)) seconds"
//                    )
//                    let image = imageResponseContainer.image
//                    bikeModel.largeImage = image.large
//                    bikeModel.thumb = image.thumb
//
//                    modelContext.insert(bikeModel)
//                    try? modelContext.save()
//                case .failure(let failure):
//                    Logger.model.debug(
//                        "\(#function) Failed to upload image after bike registration: \(failure)"
//                    )
//                }
//            } catch {
//
//            }
//        }

        /// Marshall the Bike model to a ``Postable`` intermediary, write that intermediary to the API client and discard Bike model
        /// Receive the result and persist the server's model
        /// Update the UI
        func registerBike(
            mode: RegisterMode, path: Binding<NavigationPath>, client: Client,
            modelContext: ModelContext
        ) async {
            Logger.model.debug(
                "\(#function) Registering bike w/ serial \(String(describing: self.bike.serial))")
            Logger.model.debug(
                "\(#function) Registering bike w/ manufacturerName \(String(describing: self.bike.manufacturerName))"
            )
            Logger.model.debug(
                "\(#function) Registering bike w/ frameColors \(String(describing: self.bike.frameColors))"
            )
            Logger.model.debug(
                "\(#function) Registering w/ owner email \(String(describing: self.ownerEmail))")

            let bikeRegistration = BikeRegistration(
                bike: bike,
                mode: mode,
                stolen: stolenRecord,
                propulsion: propulsion,
                ownerEmail: ownerEmail)
            let endpoint = Bikes.postBikes(form: bikeRegistration)
            let response: Result<SingleBikeResponseContainer, any Error> = await client.post(
                endpoint)
            switch response {
            case .success(let registrationResponseSource):
                do {
                    let bikeModel = registrationResponseSource.bike.modelInstance()
                    modelContext.insert(bikeModel)

                    var message: LocalizedStringKey = ""
                    let start = Date()
                    if case .success(let image) = imageState {
                        message = "Bike photo should finish uploading in the background."
                        Task {
                            // TODO: Find a way to reduce file size further without reducing quality
                            if let data = image.jpegData(compressionQuality: 0.9) {
                                let endpoint = Bikes.image(
                                    identifier: "\(bikeModel.identifier)", imageData: data)
                                client.postInBackground(endpoint) { result in
                                    do {
                                        switch result {
                                        case .success(let data):
                                            guard let imageResponseContainer = try JSONDecoder().decode(endpoint.responseModel, from: data) as? ImageResponseContainer else {
                                                Logger.model.debug(
                                                    "\(#function) Failed to decode image upload response after bike registration"
                                                )
                                                return
                                            }
                                            Logger.model.debug(
                                                "\(#function) Image upload successful in \(Date().timeIntervalSince(start)) seconds"
                                            )
                                            let image = imageResponseContainer.image
                                            bikeModel.largeImage = image.large
                                            bikeModel.thumb = image.thumb

                                            modelContext.insert(bikeModel)
                                            try? modelContext.save()
                                        case .failure(let failure):
                                            Logger.model.debug(
                                                "\(#function) Failed to upload image after bike registration: \(failure)"
                                            )
                                        }
                                    } catch {

                                    }
                                }
                            } else {
                                Logger.model.debug(
                                    "\(#function) Failed to convert image to jpeg data"
                                )
                            }
                        }
                    }

                    try? modelContext.save()
                    self.output = AddBikeOutput(
                        show: true,
                        actions: {
                            // After success, pop RegisterBikeView
                            path.wrappedValue.removeLast()
                        }, message: message, title: "Success!")
                }

            case .failure(let failure):
                Logger.views.error(
                    "Failed to register bike with model \(String(reflecting: bikeRegistration)), endpoint \(String(reflecting: endpoint))"
                )
                Logger.views.error(
                    "Failed to register bike with failure \(String(reflecting: failure)), response \(String(reflecting: response))"
                )

                self.output = AddBikeOutput(
                    show: true,
                    actions: {

                    }, message: LocalizedStringKey(failure.localizedDescription),
                    title: "Registering bike failed")
            }
        }
    }
}
