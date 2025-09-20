//
//  MailToLink.swift
//  BikeIndex
//
//  Created by Jack on 6/15/25.
//

import Foundation

enum MailToLink: Identifiable {
    case contactUs

    var id: Self { self }

    var link: URL {
        switch self {
        case .contactUs:
            let base = URL(string: "mailto:")!
            let recipient = "support+ios@bikeindex.org"

            let subject = URLQueryItem(name: "subject", value: "iOS App Help Request")
            var queryItems: [URLQueryItem] = [subject]

            let info = AppVersionInfo()
            if let marketingVersion = info.marketingVersion,
                let buildNumber = info.buildNumber
            {
                let body = URLQueryItem(
                    name: "body", value: "\r\n\r\nVersion: \(marketingVersion) (\(buildNumber))")
                queryItems.append(body)
            }

            return
                base
                .appending(path: recipient)
                .appending(queryItems: queryItems)
        }
    }
}
