//
//  StolenRecordEntryView.swift
//  BikeIndex
//
//  Created by Jack on 12/28/23.
//

import SwiftUI

struct StolenRecordEntryView: View {
    @Binding var record: StolenRecord

    var body: some View {
        Section {
            TextField("Who to contact when this bike is found", text: $record.phone)
                .keyboardType(.phonePad)

        } header: {
            Text("Phone Number")
        } footer: {
            Text("**Required** to register a stolen bike")
        }

        Section {
            Picker("Country", selection: $record.country) {
                ForEach(Countries.allCases) { country in
                    Text(country.rawValue)
                        .tag(country.isoCode as String?)
                }
            }

            TextField(
                "Address or intersection", text: Binding($record.address, replacingNilWith: ""))
            TextField("City", text: $record.city)
            TextField("Postal Code", text: Binding($record.zipcode, replacingNilWith: ""))

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
        } footer: {
            Text("**City** is required to register a stolen bike")
        }

    }
}

#Preview {
    var backingRecord = StolenRecord(phone: "", city: "")
    let record = Binding {
        backingRecord
    } set: { value in
        backingRecord = value
    }

    return Form(content: {
        StolenRecordEntryView(record: record)
    })
}
