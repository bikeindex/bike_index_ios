//
//  SearchBikesView.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import SwiftUI

struct SearchBikesView: View {
    var body: some View {
        NavigableWebView(
            url: .constant(URL("https://bikeindex.org/bikes?stolenness=all"))
        )
    }
}
