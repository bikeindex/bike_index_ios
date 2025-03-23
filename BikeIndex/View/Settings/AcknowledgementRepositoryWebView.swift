//
//  AcknowledgementRepositoryWebView.swift
//  BikeIndex
//
//  Created by Jack on 12/5/24.
//

import SwiftUI

struct AcknowledgementRepositoryWebView: View {
    @Environment(Client.self) var client

    var package: AcknowledgementPackage
    @State private var url: URL

    init(package: AcknowledgementPackage) {
        self.package = package
        self._url = State(initialValue: package.repository)
    }

    var body: some View {
        NavigableWebView(url: $url)
            .environment(client)
            .navigationTitle(package.title)
    }
}
