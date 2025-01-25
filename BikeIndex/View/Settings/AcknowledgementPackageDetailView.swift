//
//  AcknowledgementPackageView.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import SwiftUI

struct AcknowledgementPackageDetailView: View {
    let package: AcknowledgementPackage
    @Binding var showRepositoryUrl: Bool

    var body: some View {
        Text(package.fullLicense())
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(
                        action: {
                            showRepositoryUrl = true
                        },
                        label: {
                            Label("Open Repository", systemImage: "link")
                        })
                }
            }
            .navigationTitle(package.title)
    }
}

#Preview {
    let package = AcknowledgementPackage(
        title: "BikeIndex iOS",
        license: .gnuAfferoGPLv3,
        copyright: "2023 © Bike Index, a 501(c)(3) nonprofit - EIN 81-4296194",
        repository: URL(string: "https://github.com/bikeindex/bike_index_ios")!)
    let showUrl: Binding<Bool> = Binding {
        false
    } set: { _ in
    }

    return NavigationStack {
        AcknowledgementPackageDetailView(package: package, showRepositoryUrl: showUrl)
            .navigationTitle("BikeIndex iOS")
            .navigationBarTitleDisplayMode(.inline)
    }
}
