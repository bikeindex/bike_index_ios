//
//  Acknowledgements.swift
//  BikeIndex
//
//  Created by Jack on 1/6/24.
//

import SwiftUI

struct Package: Identifiable, Hashable {
    var id: String { title }

    let title: String
    let license: License
    let description: String

    func fullLicense() -> String {
        license.with(copyright: description)
    }
}

struct AcknowledgementsView: View {
    var packages: [Package] = [
        Package(title: "BetterSafariView", license: .mit, description: "Copyright (c) 2020 Dongkyu Kim"),
        Package(title: "KeychainSwift", license: .mit, description: "Copyright (c) 2015 - 2021 Evgenii Neumerzhitckii"),
        Package(title: "URLEncodedForm", license: .mit, description: "Copyright (c) 2023 Scott Moon"),
    ]

    var body: some View {
        List(packages) { package in
            NavigationLink {
                ScrollView {
                    Text(package.fullLicense())
                        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
            .navigationTitle("Acknowledgements")
    }
}
