//
//  RequiredField.swift
//  BikeIndex
//
//  Created by Jack on 8/9/25.
//

import SwiftUI

struct RequiredField: View {
    var valid: Bool
    var label: String

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.footnote)
                .baselineOffset(0)

            if valid {
                Text(" ✔︎")
                    .bold()
                    .accessibilityLabel("Valid \(label)")
            } else {
                Text("*")
                    .bold()
                    .foregroundColor(.red)
                    .accessibilityLabel("Required \(label)")
            }
        }
    }
}

struct PrimaryFrameColorRequiredField: View {
    let valid = true
    let label = "Primary Frame Color"

    var body: some View {
        HStack(spacing: 0) {
            Text(label)

            if valid {
                Text(" ✔︎")
                    .bold()
                    .baselineOffset(2)
                    .accessibilityLabel("Valid \(label)")
            } else {
                Text("*")
                    .bold()
                    .baselineOffset(2)
                    .foregroundColor(.red)
                    .accessibilityLabel("Required \(label)")
            }
        }
    }
}
