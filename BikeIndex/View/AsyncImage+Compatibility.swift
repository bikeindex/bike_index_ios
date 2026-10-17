//
//  AsyncImage+Compatibility.swift
//  BikeIndex
//
//  Created by Jack on 10/8/26.
//

import CachedAsyncImage
import SwiftUI

/// Remove when deployment target meets or exceeds iOS 27.0
struct CompatibleAsyncImage<Content>: View where Content: View {

    var url: URL?
    @ViewBuilder var content: (AsyncImagePhase) -> Content

    var body: some View {
        if #available(iOS 27.0, *) {
            AsyncImage(url: url, content: content)
        } else {
            CachedAsyncImage(url: url, content: content)
        }
    }
}
