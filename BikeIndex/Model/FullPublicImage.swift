//
//  FullPublicImage.swift
//  BikeIndex
//
//  Created by Jack on 12/15/25.
//

import Foundation
import SwiftData

// TODO: https://github.com/bikeindex/bike_index_ios/pull/107 - MOVE TO MODEL DIRECTORY
@Model final class FullPublicImage {
    @Relationship(inverse: \Bike.fullPublicImages)
    var bike: Bike?

    var name: String
    var full: URL?
    var large: URL?
    var medium: URL?
    var thumb: URL?
    var id: Int

    init(
        bike: Bike? = nil, name: String, full: URL?, large: URL?, medium: URL?, thumb: URL?, id: Int
    ) {
        self.bike = bike
        self.name = name
        self.full = full
        self.large = large
        self.medium = medium
        self.thumb = thumb
        self.id = id
    }
}
