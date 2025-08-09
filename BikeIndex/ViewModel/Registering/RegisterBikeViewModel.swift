//
//  RegisterBikeViewModel.swift
//  BikeIndex
//
//  Created by Jack on 8/7/25.
//

import Combine
import Foundation
import OSLog
import SwiftData
import SwiftUI

extension RegisterBikeView {
    @Observable @MainActor
    class ViewModel: ObservableObject {
        // MARK: Authoritative State
        /// Primary model to mutate and persist
        var bike = Bike()
        /// Sub-model for electric/throttle/pedal-assist behavior. Will be combined with BikeRegistration inside ``registerBike()`` function.
        var propulsion = BikeRegistration.Propulsion()
        var stolenRecord = StolenRecord(phone: "", city: "")
        /// Track if any errors occurred when submitting this bike
        var validationModel = AddBikeOutput()

        // MARK: Shadow State
        // Shadow the serial number, manufacturer, and model to update the UI without unwrapping optionals
        var missingSerial = false
        /// Track the search field value for the manufacturer query _and_ value.
        var manufacturerSearchText = ""
        var frameModel = ""

        /* Shadow the Bike.frameColors selection with local state to bridge the gap between Binding<FrameColor>
         * Picker(selection:) changes and updating the Bike [FrameColor] array.
         */
        var colorPrimary = FrameColor.defaultColor
        var colorSecondary = FrameColor.defaultColor
        var colorTertiary = FrameColor.defaultColor

        /// Shadow over Bike cycleType in case there is a non-default value
        var traditionalBicycle = true
        /// Shadow over the User.email in case there are local changes
        var ownerEmail: String = ""

        /// Required fields include
        /// 1. serialNumber not empty || missingSerialNumber == true
        /// 2. manufacturer not empty
        /// 3. Primary frame color not empty
        /// 4. owner email
        /// Source: attempt to register on the web with any string for the serial number
        var requiredFieldsNotMet: Bool {
            // Serial is required, unless marked missing/unidentified
            // There's also made_without_Serial but that's a more complicated scenario
            // Frame color is assigned by default
            // Email is required, unless the bike is abandoned/impounded
            !(isSerialNumberValid
                && isManufacturerValid
                && isOwnerValid)
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
        }

        func validateEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil)
                != nil
        }

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
            let response: Result<SingleBikeResponseContainer, any Error> = await client.api.post(
                endpoint)
            switch response {
            case .success(let registrationResponseSource):
                do {
                    let bikeModel = registrationResponseSource.bike.modelInstance()
                    modelContext.insert(bikeModel)

                    try? modelContext.save()
                    self.validationModel = AddBikeOutput(
                        show: true,
                        actions: {
                            // After success, pop RegisterBikeView
                            path.wrappedValue.removeLast()
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
}
