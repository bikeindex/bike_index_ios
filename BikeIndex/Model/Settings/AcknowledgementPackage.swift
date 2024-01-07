//
//  Package.swift
//  BikeIndex
//
//  Created by Jack on 1/7/24.
//

import Foundation

struct AcknowledgementPackage: Identifiable, Hashable {
    var id: String { title }

    let title: String
    let license: License
    let description: String
    let repository: URL?

    func fullLicense() -> String {
        license.with(copyright: description)
    }
}

extension AcknowledgementPackage {
    static var all: [AcknowledgementPackage] = [
        // MARK: GNU AGPL v3.0
        AcknowledgementPackage(title: "Bike Index",
                license: .gnuAfferoGPLv3,
                description: "2023 © Bike Index, a 501(c)(3) nonprofit - EIN 81-4296194",
                repository: URL(string: "https://github.com/bikeindex/bike_index")),
        AcknowledgementPackage(title: "Bike Index iOS",
                license: .gnuAfferoGPLv3,
                description: "2023 © Bike Index, a 501(c)(3) nonprofit - EIN 81-4296194",
                repository: URL(string: "https://github.com/bikeindex/bike_index_ios")),

        // MARK: MIT
        AcknowledgementPackage(title: "BetterSafariView",
                license: .mit,
                description: "Copyright (c) 2020 Dongkyu Kim",
                repository: URL(string: "https://github.com/stleamist/BetterSafariView")),
        AcknowledgementPackage(title: "KeychainSwift",
                license: .mit,
                description: "Copyright (c) 2015 - 2021 Evgenii Neumerzhitckii",
                repository: URL(string: "https://github.com/evgenyneu/keychain-swift")),
        AcknowledgementPackage(title: "URLEncodedForm",
                license: .mit,
                description: "Copyright (c) 2023 Scott Moon",
                repository: URL(string: "https://github.com/forXifLess/URLEncodedForm")),
    ]

    static var gnuAfferoGPLv3Packages: [AcknowledgementPackage] {
        AcknowledgementPackage.all.filter { $0.license == .gnuAfferoGPLv3 }
    }

    static var mitPackages: [AcknowledgementPackage] {
        AcknowledgementPackage.all.filter { $0.license == .mit }
    }
}
