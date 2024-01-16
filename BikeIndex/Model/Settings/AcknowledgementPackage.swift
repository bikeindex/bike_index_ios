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
    let copyright: String
    let repository: URL?

    func fullLicense() -> String {
        license.with(copyright: copyright)
    }
}

extension AcknowledgementPackage {
    static var all: [AcknowledgementPackage] = [
        // MARK: GNU AGPL v3.0
        AcknowledgementPackage(title: "Bike Index",
                               license: .gnuAfferoGPLv3,
                               copyright: "2023 © Bike Index, a 501(c)(3) nonprofit - EIN 81-4296194",
                               repository: URL(string: "https://github.com/bikeindex/bike_index")),
        AcknowledgementPackage(title: "Bike Index iOS",
                               license: .gnuAfferoGPLv3,
                               copyright: "2023 © Bike Index, a 501(c)(3) nonprofit - EIN 81-4296194",
                               repository: URL(string: "https://github.com/bikeindex/bike_index_ios")),

        // MARK: MIT
        AcknowledgementPackage(title: "KeychainSwift",
                               license: .mit,
                               copyright: "Copyright © 2015 - 2021 Evgenii Neumerzhitckii",
                               repository: URL(string: "https://github.com/evgenyneu/keychain-swift")),
        AcknowledgementPackage(title: "URLEncodedForm",
                               license: .mit,
                               copyright: "Copyright © 2023 Scott Moon",
                               repository: URL(string: "https://github.com/forXifLess/URLEncodedForm")),
        AcknowledgementPackage(title: "WebViewKit",
                               license: .mit,
                               copyright: "Copyright © 2022 Daniel Saidi",
                               repository: URL(string: "https://github.com/danielsaidi/WebViewKit")),
        AcknowledgementPackage(title: "FontKit",
                               license: .mit,
                               copyright: "Copyright © 2022 VishwaiOSDev",
                               repository: URL(string: "https://github.com/VishwaiOSDev/FontKit")),

        // MARK: Open Font
        AcknowledgementPackage(title: "Open Sans",
                               license: .openFontLicense,
                               copyright: "Copyright © 2021, Steve Matteson (https://mattesontypographics.com/),\nwith Reserved Font Name OpenSans.",
                               repository: URL(string: "https://fonts.google.com/specimen/Open+Sans/about"))
    ]

    static var gnuAfferoGPLv3Packages: [AcknowledgementPackage] {
        AcknowledgementPackage.all.filter { $0.license == .gnuAfferoGPLv3 }
    }

    static var mitPackages: [AcknowledgementPackage] {
        AcknowledgementPackage.all.filter { $0.license == .mit }
    }

    static var fontPackages: [AcknowledgementPackage] {
        AcknowledgementPackage.all.filter { $0.license == .openFontLicense }
    }
}
