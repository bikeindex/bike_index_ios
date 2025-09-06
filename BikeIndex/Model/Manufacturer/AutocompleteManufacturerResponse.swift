//
//  AutocompleteManufacturerResponse.swift
//  BikeIndex
//
//  Created by Jack on 1/1/24.
//

import Foundation

/// API endpoint: api/autocomplete
struct AutocompleteManufacturerContainerResponse: ResponseDecodable {
    var matches: [AutocompleteManufacturerResponse]
}

struct AutocompleteManufacturerResponse: ResponseModelInstantiable, ResponseDecodable {
    var text: String
    var category: String
    var slug: String
    var priority: Int
    var search_id: String
    var id: Int

    // MARK: - ResponseModelInstantiable
    typealias ModelInstance = AutocompleteManufacturer

    func modelInstance() -> ModelInstance {
        AutocompleteManufacturer(
            text: text,
            category: category,
            slug: slug,
            priority: priority,
            searchId: search_id,
            identifier: id)
    }
}
