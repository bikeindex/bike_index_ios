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
    @State var viewModel: ViewModel

    init(scan: ScannedBike) {
        self.viewModel = ViewModel(scan: scan)
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            // TODO: When a guest user taps sign-in this should open the **native** sign-in
            NavigableWebView(url: $viewModel.scan.url,
                             navigator: .guestNavigator(viewModel: viewModel))
                .environment(client)
                .navigationTitle(viewModel.title)
                .onAppear {
                    print("Opening \(viewModel.scan.url)")
                }
        }
    }
}

#Preview {
//    ScannedBike(url: URL(stringLiteral: "https://bikeindex.org/bikes/scanned/A40340"))
//        .environment(try Client())
}

extension ScannedBikePage {
    @Observable
    final class ViewModel {
        var scan: ScannedBike
        var path = NavigationPath()

        var title: String {
            scan.identifier
        }

        init(scan: ScannedBike) {
            self.scan = scan
            self.path = path
        }
    }
}

final class GuestNavigator: NavigationResponder {
    var viewModel: ScannedBikePage.ViewModel

    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        // TODO: Intercept requests for sign-in page, and substitute the native sign-in
        // TODO: **OR** even better, let it proceed and then just dismiss it —— but this will need to work with the view models and window group probably —— and also work with authenticated users (don't degrade their experience, and make sure only the necessary flows are involved.

        // AuthView does a lot of extra work to make sure that sign-in works

        if navigationAction.request.url == URL(string: "https://bikeindex.org/session/new") {
//            viewModel.path
        }

        return (.allow, preferences)
    }

    init(viewModel: ScannedBikePage.ViewModel) {
        self.viewModel = viewModel
    }
}

extension NavigationResponder {
    /// Responder chain in action!
    static func guestNavigator(viewModel: ScannedBikePage.ViewModel) -> HistoryNavigator {
        HistoryNavigator(
            child: AuthenticationNavigator(
                child: GuestNavigator(viewModel: viewModel)
            )
        )
    }
}
