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
    @State private var showRepositoryUrl = false

    var body: some View {
        NavigationLink {
            ScrollView {
                AcknowledgementPackageDetailView(
                    package: package,
                    showRepositoryUrl: $showRepositoryUrl
                )
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $showRepositoryUrl) {
                AcknowledgementRepositoryWebView(package: package)
            }
        } label: {
            VStack(alignment: .leading) {
                Text(package.title)
                    .font(.title3)
                Text(package.license.name)
                Text(package.copyright)
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

            if !AcknowledgementPackage.fontPackages.isEmpty {
                Section {
                    List(AcknowledgementPackage.fontPackages) { package in
                        AcknowledgementListItemView(package: package)
                    }
                } header: {
                    Text("Fonts")
                }
            }
        }
        .navigationTitle("Acknowledgements")
    }
}

#Preview("AcknowledgementListItemView") {
    AcknowledgementListItemView(
        package: AcknowledgementPackage.all.first(where: { $0.title == "Bike Index" })
            .unsafelyUnwrapped
    )
    .environment(try! Client())
}

#Preview {
    NavigationStack {
        AcknowledgementsListView()
            .environment(try! Client())
            .navigationTitle("Acknowledgements")
    }
}
