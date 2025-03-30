//
//  ScannedBikePage.swift
//  BikeIndex
//
//  Created by Jack on 3/29/25.
//

import SwiftUI
import WebKit
import OSLog

struct ScannedBikePage: View {
    @Environment(Client.self) var client
    @State var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            NavigableWebView(
                url: .constant(viewModel.scan.url),
                navigator: .guestNavigator(viewModel: viewModel)
            )
            .environment(client)
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        viewModel.dismiss()
                    }
                }
            }
            .onAppear {
                Logger.views.debug("ScannedBikePage opening \(viewModel.scan.url)")
            }
        }
    }
}

extension ScannedBikePage {
    @Observable
    final class ViewModel {
        var scan: ScannedBike
        var path: NavigationPath
        var dismiss: () -> Void
        var onDisappear: MainContent?

        var title: String {
            scan.sticker.identifier
        }

        init(scan: ScannedBike, path: NavigationPath, dismiss: @escaping () -> Void) {
            self.scan = scan
            self.path = path
            self.dismiss = dismiss
        }
    }
}

@Observable
final class GuestNavigator: NavigationResponder {
    var viewModel: ScannedBikePage.ViewModel

    override func webView(
        _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        // TODO: Intercept requests for sign-in page, and substitute the native sign-in
        // TODO: **OR** even better, let it proceed and then just dismiss it —— but this will need to work with the view models and window group probably —— and also work with authenticated users (don't degrade their experience, and make sure only the necessary flows are involved.

        // AuthView does a lot of extra work to make sure that sign-in works

        // NICE TO HAVE: Native Bike details displaydismiss scanned page, push bike page by identifier, and cancel the web navigation -- but this cannot be built until the BikeDetailView can track association of the bike-detail sticker so we need to make sure that is brou;gh along for the ride
        //        if navigationAction.request.url == URL(string: "https://bikeindex.org/bikes/2553556") {
        //            viewModel.path.append("2553556")
        //        }

        if let url = navigationAction.request.url,
           url == URL(string: "https://bikeindex.org/bikes/new?bike_sticker=A40340")
        {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            // TODO: Native QR code registration
            //viewModel.dismiss()
            //viewModel.onDisappear = MainContent.registerBike
            //return (.cancel, preferences)
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
            child: GuestNavigator(viewModel: viewModel)
        )
    }
}
