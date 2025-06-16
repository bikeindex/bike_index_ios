//
//  TextLink.swift
//  BikeIndex
//
//  Created by Jack on 11/23/23.
//

import SwiftUI

/// Display constant and clickable Markdown links for Production
/// Display dynamic and non-clickable Markdown links for Development
///
/// Why does this exist??
/// `Text` does **not** support `URL`s. You must provide a constant _string_.
struct TextLink: View {
    var base: URL
    var link: BikeIndexLink

    var body: some View {
        Text(link.on(base))
    }
}

#Preview {
    let localhost = URL(stringLiteral: "http://localhost")
    return VStack {
        ForEach([BikeIndexLink.oauthApplications, .serials, .stolenBikeFAQ]) { item in
            TextLink(base: localhost, link: item)
                .padding()
            Spacer()
        }
    }
}
