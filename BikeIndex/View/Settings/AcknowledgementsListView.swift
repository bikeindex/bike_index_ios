//
//  Acknowledgements.swift
//  BikeIndex
//
//  Created by Jack on 1/6/24.
//

import SwiftUI
import WebViewKit

struct AcknowledgementListItemView: View {
    @Environment(Client.self) private var client
    var package: AcknowledgementPackage
    @State private var repositoryUrl: URL?

    var body: some View {
        NavigationLink {
            ScrollView {
                AcknowledgementPackageDetailView(package: package, url: $repositoryUrl)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(item: $repositoryUrl) { url in
                WebView(url: url,
                        configuration: client.webConfiguration,
                        viewConfiguration: WebView.inspectable)
            }
        } label: {
            VStack(alignment: .leading) {
                Text(package.title)
                    .font(.title3)
                Text(package.license.name)
                Text(package.description)
            }
        }
    }
}

struct AcknowledgementsListView: View {
    var body: some View {
        Form {
            Section {
                List(AcknowledgementPackage.gnuAfferoGPLv3Packages) { package in
                    AcknowledgementListItemView(package: package)
                }
            } header: {
                Text("All the code for Bike Index, \nbecause we love you")
                    .textCase(nil)
            }

            Section {
                List(AcknowledgementPackage.mitPackages) { package in
                    AcknowledgementListItemView(package: package)
                }
            } header: {
                Text("iOS PACKAGES")
                    .textCase(nil)
            }
        }
        .navigationTitle("Acknowledgements")
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsListView()
            .navigationTitle("Acknowledgements")
    }
}
