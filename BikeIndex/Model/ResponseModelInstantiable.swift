//
//  into.swift
//  BikeIndex
//
//  Created by Jack on 8/9/25.
//

import Foundation

/// Convert a network response from a Decodable struct into its corresponding @Model class instance.
protocol ResponseModelInstantiable: Decodable {
    associatedtype ModelInstance

    func modelInstance() -> ModelInstance
}
