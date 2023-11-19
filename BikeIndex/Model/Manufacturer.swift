//
//  Manufacturer.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import Foundation
import SwiftData

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

//@Model class Manufacturer: Codable {
/*
 self.name = InputNormalizer.string(name)
 self.slug = Slugifyer.manufacturer(name)
 self.website = website.present? ? Urlifyer.urlify(website) : nil
 self.logo_source = logo.present? ? (logo_source || "manual") : nil
 self.twitter_name = twitter_name.present? ? twitter_name.gsub(/\A@/, "") : nil
 self.description = nil if description.blank?
 self.priority = calculated_priority # scheduled updates via UpdateManufacturerLogoAndPriorityWorker

 */
//}

//extension Manufacturer: Decodable {
//
//}
