//
//  ComponentsResponse.swift
//  BikeIndex
//
//  Created by Jack on 5/2/26.
//

import Foundation

// TODO: CHECK ALL TYPE
struct ComponentsResponse: ResponseModelInstantiable {
    let id: Int
    let description: String
    let serial_number: String
    let component_type: String  // TODO: check type
    let component_group: String
    let rear: Int?  // TODO: check type
    let front: Int?  // TODO: check type
    let manufacturer_name: String?  // TODO: check type
    let model_name: String
    let year: Int

    func modelInstance() -> Component {
        Component(
            id: id,
            description: description,
            serial_number: serial_number,
            component_type: component_type,
            component_group: component_group,
            model_name: model_name,
            year: year)
    }
}
