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

#Preview("RequiredField Design Sheet") {
    List {
        Section {
            Text("System default header")
        } header: {
            Text("Control")
        }

        Section {
            Text("Content")
        } header: {
            RequiredField(
                valid: true,
                label: "Valid")
        }

        Section {
            Text("Content")
        } header: {
            RequiredField(
                valid: false,
                label: "Invalid")
        }

        Section {
            RequiredField(valid: true, label: "Primary Frame Color")
        } header: {
            Text("In-line usage for PrimaryFrameColor")
        }
    }
}
