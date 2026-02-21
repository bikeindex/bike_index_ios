//
//  StolenRecordEntryView.swift
//  BikeIndex
//
//  Created by Jack on 12/28/23.
//

import SwiftUI

struct StolenRecordEntryView: View {
    @Binding var record: RegisterBikeStolenRecord
    @FocusState.Binding var focus: RegisterBikeView.Field?

    var body: some View {
        Section {
            TextField(
                "Who to contact when this bike is found",
                text: $record.phone
            )
            .keyboardType(.phonePad)
            .focused($focus, equals: .phoneNumber)
            .id(RegisterBikeView.Field.phoneNumber)
        } header: {
            RequiredField(
                valid: record.isPhoneValid,
                label: "Phone Number")
        } footer: {
            Text("Phone Number is required to register a stolen bike")
        }

        Section {
            Picker("Country", selection: $record.country) {
                ForEach(Countries.allCases) { country in
                    Text(country.rawValue)
                        .tag(country.isoCode as String?)
                }
            }

            TextField(
                "Address or intersection", text: Binding($record.address, replacingNilWith: "")
            )
            .focused($focus, equals: .addressOrIntersection)
            .id(RegisterBikeView.Field.addressOrIntersection)

            LabeledContent {
                TextField("City is required", text: $record.city)
                    .focused($focus, equals: .city)
                    .id(RegisterBikeView.Field.city)
            } label: {
                RequiredField(
                    valid: record.isCityValid,
                    label: "City"
                )
                .foregroundStyle(.secondary)
            }

            LabeledContent {
                TextField("", text: Binding($record.zipcode, replacingNilWith: ""))
                    .focused($focus, equals: .postalCode)
                    .id(RegisterBikeView.Field.postalCode)
            } label: {
                Text("Postal Code")
                    .foregroundStyle(.secondary)
            }

            if let country = record.country,
                country == Countries.us.isoCode
            {
                Picker("State", selection: $record.state) {
                    Text("No selection").tag(nil as String?)
                    ForEach(US_States.allCases) { state in
                        Text(state.rawValue)
                            .tag(state.abbreviation as String?)
                    }
                }
            }

        } header: {
            Text("Where was it stolen?")
        }

    }
}

#Preview {
    @Previewable @State var record = RegisterBikeStolenRecord(phone: "", city: "")
    @Previewable @FocusState var focus: RegisterBikeView.Field?

    Form {
        StolenRecordEntryView(
            record: $record,
            focus: $focus)
    }
}
