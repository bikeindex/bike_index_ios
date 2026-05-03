//
//  ComponentsResponse.swift
//  BikeIndex
//
//  Created by Jack on 5/2/26.
//

import Foundation

/// Component Types and Groups should be a string to match API dynamism
/// https://github.com/bikeindex/bike_index/blob/main/db/seeds/seed_components.rb#L11
struct ComponentsResponse: ResponseModelInstantiable {
    let id: Int
    let description: String
    let serial_number: String?
    let component_type: String
    let component_group: String
    let rear: Bool?
    let front: Bool?
    let manufacturer_name: String?
    let model_name: String?
    let year: Int?

    func modelInstance() -> Component {
        Component(
            id: id,
            componentDescription: description,
            serial_number: serial_number,
            component_type: component_type,
            component_group: component_group,
            model_name: model_name,
            year: year)
    }
}

extension [ComponentsResponse] {
    func modelInstances() -> [ComponentsResponse.ModelInstance] {
        self.map { $0.modelInstance() }
    }
}
