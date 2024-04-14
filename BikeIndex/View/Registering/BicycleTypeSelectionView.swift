//
//  BicycleTypeSelectionView.swift
//  BikeIndex
//
//  Created by Jack on 3/24/24.
//

import SwiftUI

struct BicycleTypeSelectionView: View {
    /// Model provided by parent view to write changes to
    @Binding var bike: Bike

    /// Transient view-only state reflecting traditional foot-pedal / non-electric bicycle
    @Binding var traditionalBicycle: Bool

    /// View-only state belonging to the parent view that contains just motor info (electric/pedal-assist/throttle
    @Binding var propulsion: BikeRegistration.Propulsion

    var body: some View {
        if traditionalBicycle {
            Section {
                Toggle("Traditional bicycle", isOn: $traditionalBicycle)
            } header: {
                Text("Bicycle Type")
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
                if bike.typeOfCycle.canBeElectric {
                    Toggle("⚡️ Electric (motorized)",
                           isOn: $propulsion.isElectric)

                    if bike.typeOfCycle.pedalAssistAndThrottle {
                        // not applicable for stroller/wheelchair/e-scooter/personal-mobility
                        Toggle("Throttle", isOn: $propulsion.hasThrottle)
                            .disabled(!propulsion.isElectric)
                        Toggle("Pedal Assist", isOn: $propulsion.hasPedalAssist)
                            .disabled(!propulsion.isElectric)
                    }
                }
            } header: {
                Text("Bicycle Type")
            } footer: {
                EmptyView()
            }
        }

    }
}

#Preview {
    var previewBike: Bike = Bike()
    let bikeBinding = Binding {
        previewBike
    } set: { newValue in
        previewBike = newValue
    }

    var previewPropulsion = BikeRegistration.Propulsion()
    let propulsionBinding = Binding {
        previewPropulsion
    } set: { newValue in
        previewPropulsion = newValue
    }

    return Form {
        BicycleTypeSelectionView(
            bike: bikeBinding,

            traditionalBicycle: .constant(true),
            propulsion: propulsionBinding
        )
    }
}
