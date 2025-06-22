//
//  StolenBikeInfoSectionView.swift
//  BikeIndex
//
//  Created by Jack on 5/4/25.
//

import SwiftUI

/// Used to display information and help pages
struct StolenBikeInfoSectionView: View {
    @Environment(Client.self) var client
    var body: some View {
        Section {
            NavigationLink {
                NavigableWebView(
                    constantLink: .stolenBikeWhatToDo,
                    host: client.configuration.host
                )
                .environment(client)
            } label: {
                Text("What to do if your bike is stolen")
            }
            NavigationLink {
                NavigableWebView(
                    constantLink: .stolenBikeFAQ,
                    host: client.configuration.host
                )
                .environment(client)
            } label: {
                Text("How to get your stolen bike back")
            }
        } header: {
            Text("⚠️ Information")
        }
    }
}
