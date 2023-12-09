//
//  Manufacturer.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData

/// API endpoint: api/autocomplete
final class AutocompleteResponse: Decodable {
    var matches: [AutocompleteManufacturer]
}

@Model class AutocompleteManufacturer: Decodable {
    var text: String
    var category: String
    var slug: String
    var priority: Int
    var searchId: String
    @Attribute(.unique) var identifier: Int

    init(text: String, category: String, slug: String, priority: Int, searchId: String, identifier: Int) {
        self.text = text
        self.category = category
        self.slug = slug
        self.priority = priority
        self.searchId = searchId
        self.identifier = identifier
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        category = try container.decode(String.self, forKey: .category)
        slug = try container.decode(String.self, forKey: .slug)
        priority = try container.decode(Int.self, forKey: .priority)
        searchId = try container.decode(String.self, forKey: .searchId)
        identifier = try container.decode(Int.self, forKey: .identifier)
    }

    enum CodingKeys: String, CodingKey {
        case text
        case category
        case slug
        case priority
        case searchId = "search_id"
        case identifier = "id"
    }
}
