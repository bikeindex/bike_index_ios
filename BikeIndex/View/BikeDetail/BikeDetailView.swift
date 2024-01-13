//
//  BikeDetailView.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftUI
import WebKit
import WebViewKit

struct BikeDetailView: View {
    @Environment(Client.self) var client

    var bike: Bike
    @State var url: URL?

    var body: some View {
        VStack {
            Text("bike!")
            NavigationLink("Edit") {
                WebView(url: bike.editUrl)
            }
        }
    }
}

/*
 https://bikeindex.org/bikes/2553556/edit/bike_details
 https://bikeindex.org/bikes/2553556/edit/photos
 https://bikeindex.org/bikes/2553556/edit/drivetrain
 https://bikeindex.org/bikes/2553556/edit/accessories
 https://bikeindex.org/bikes/2553556/edit/ownership
 https://bikeindex.org/bikes/2553556/edit/groups
 https://bikeindex.org/bikes/2553556/edit/remove
 https://bikeindex.org/bikes/2553556/edit/versions
 https://bikeindex.org/bikes/2553556/edit/report_stolen
 */
