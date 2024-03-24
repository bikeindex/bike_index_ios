//
//  BicycleTypeSelectionView.swift
//  BikeIndex
//
//  Created by Jack on 3/24/24.
//

import SwiftUI

struct BicycleTypeSelectionView: View {
    @Binding var bike: Bike
    @Binding var traditionalBicycle: Bool

    var body: some View {
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
                if bike.typeOfCycle.canBeElectric {
                    Toggle("⚡️ Electric (motorized)", isOn: .constant(false))

                    if bike.typeOfCycle.pedalAssistAndThrottle {
                        // not applicable for stroller/wheelchair/e-scooter/personal-mobility
                        Toggle("Throttle", isOn: .constant(false))
                        Toggle("Pedal Assist", isOn: .constant(false))
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

    return Form {
        BicycleTypeSelectionView(bike: bikeBinding,
                                 traditionalBicycle: .constant(true))
    }
}
