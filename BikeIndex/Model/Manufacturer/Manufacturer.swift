//
//  Manufacturer.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData

/// Corresponds to https://github.com/bikeindex/bike_index/blob/main/app/models/manufacturer.rb#L24
@Model class AutocompleteManufacturer {
    var text: String
    var category: String
    var slug: String
    var priority: Int
    var searchId: String
    @Attribute(.unique) var identifier: Int

    init(
        text: String, category: String, slug: String, priority: Int, searchId: String,
        identifier: Int
    ) {
        self.text = text
        self.category = category
        self.slug = slug
        self.priority = priority
        self.searchId = searchId
        self.identifier = identifier
    }
}
