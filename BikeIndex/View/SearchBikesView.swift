//
//  SearchBikesView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftData
import SwiftUI

struct SearchBikesView: View {
    @Environment(Client.self) var client

    var body: some View {
        NavigableWebView(
            url: .constant(URL(stringLiteral: "https://bikeindex.org/bikes?stolenness=all"))
        )
        .navigationTitle(Text("Search Bikes"))
    }
}

#Preview {
    NavigationStack {
        SearchBikesView()
            .environment(try! Client())
    }
}
