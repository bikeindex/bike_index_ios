//
//  BikeDetailHeroPhotos.swift
//  BikeIndex
//
//  Created by Jack on 6/16/25.
//

import CachedAsyncImage
import SwiftUI

struct BikeDetailHeroPhotos: View {
    var bike: Bike

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                let largeImage: [URL] = [bike.largeImage]
                    .compactMap { $0 }
                let publicImages = bike.publicImages.compactMap(URL.init(string:))
                let allImages = largeImage + publicImages
                let imageUrls = allImages.enumerated().map { (offset: $0, element: $1) }
                ForEach(imageUrls, id: \.offset) { index, url in
                    CachedAsyncImage(url: url) { image in
                        switch image {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                        case .empty, .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            Image(systemName: "photo")
                        }
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
        }
        .frame(
            maxHeight: 200
        )

    }
}
