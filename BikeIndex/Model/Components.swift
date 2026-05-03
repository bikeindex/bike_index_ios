//
//  Components.swift
//  BikeIndex
//
//  Created by Jack on 5/2/26.
//

import Foundation
import SwiftData

@Model final class Component {
    @Relationship(inverse: \Bike.components)
    var bike: Bike?

    var id: Int
    /// Maps to 'description'
    var componentDescription: String
    var serialNumber: String?
    var componentType: String
    var componentGroup: String
    var rear: Bool?
    var front: Bool?
    var manufacturerName: String?
    var modelName: String?
    var year: Int?

    init(
        id: Int, componentDescription: String, serial_number: String? = nil, component_type: String,
        component_group: String, rear: Bool? = nil, front: Bool? = nil,
        manufacturer_name: String? = nil, model_name: String? = nil, year: Int? = nil
    ) {
        self.id = id
        self.componentDescription = componentDescription
        self.serialNumber = serial_number
        self.componentType = component_type
        self.componentGroup = component_group
        self.rear = rear
        self.front = front
        self.manufacturerName = manufacturer_name
        self.modelName = model_name
        self.year = year
    }
}
