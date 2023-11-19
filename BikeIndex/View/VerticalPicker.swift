//
//  VerticalPicker.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI

enum GlobalSearchMode: String, CaseIterable, Identifiable, Hashable {
    case withinHundredMiles = "Stolen within 100 miles of you"
    case stolenAnywhere = "Stolen anywhere"
    case notMarkedStolen = "Not marked stolen"
    case all = "All"

    var id: Self { return self }
}

struct VerticalPicker: View {
    @Binding var activeMode: GlobalSearchMode

    var body: some View {
        List {
            ForEach(GlobalSearchMode.allCases, id: \.id) { mode in
                if mode == activeMode {
                    HStack {
                        Text(mode.rawValue)
                        Text("✅")
                    }
                } else {
                    Text(mode.rawValue)
                        .tag(mode)
                        .onTapGesture {
                            activeMode = mode
                        }
                }
            }
        }
        .scrollDisabled(true)
    }
}

#Preview {
    var mode = GlobalSearchMode.notMarkedStolen
    let binding = Binding(get: { mode }, set: { mode = $0 })
    return VerticalPicker(activeMode: binding)
}
