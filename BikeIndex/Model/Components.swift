//
//  Components.swift
//  BikeIndex
//
//  Created by Jack on 5/2/26.
//

import Foundation
import SwiftData

// TODO: CHECK ALL TYPES
@Model final class Component {
//    @Relationship(inverse: \Bike.components)
//    var bike: Bike?

    var id: Int
    /// Maps to 'description'
    var componentDescription: String
    var serial_number: String
    var component_type: String  // TODO: check type
    var component_group: String
    var rear: Int?  // TODO: check type
    var front: Int?  // TODO: check type
    var manufacturer_name: String?  // TODO: check type
    var model_name: String
    var year: Int

    init(
        id: Int, description: String, serial_number: String, component_type: String,
        component_group: String, rear: Int? = nil, front: Int? = nil,
        manufacturer_name: String? = nil, model_name: String, year: Int
    ) {
        self.id = id
        self.componentDescription = description
        self.serial_number = serial_number
        self.component_type = component_type
        self.component_group = component_group
        self.rear = rear
        self.front = front
        self.manufacturer_name = manufacturer_name
        self.model_name = model_name
        self.year = year
    }
}
