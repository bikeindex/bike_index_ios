//
//  ScannedBikePage.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import SwiftUI
import WebKit

struct ScannedBikePage: View {
    @Environment(Client.self) var client
    @State var scan: ScannedBike

    var body: some View {
        // TODO: When a guest user taps sign-in this should open the **native** sign-in
        NavigableWebView(url: $scan.url,
                         navigator: GuestNavigator())
            .environment(client)
            .onAppear {
                print("Opening \(scan.url)")
            }
    }
}

#Preview {
//    ScannedBike(url: URL(stringLiteral: "https://bikeindex.org/bikes/scanned/A40340"))
//        .environment(try Client())
}

class GuestNavigator: HistoryNavigator {

    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {

        // TODO: Intercept requests for sign-in page, and substitute the native sign-in
        // TODO: **OR** even better, let it proceed and then just dismiss it —— but this will need to work with the view models and window group probably —— and also work with authenticated users (don't degrade their experience, and make sure only the necessary flows are involved.

        return .allow
    }
}
