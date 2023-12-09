//
//  BikeIndexIdentifiable.swift
//  BikeIndex
//
//  Created by Jack on 12/3/23.
//

import Foundation

/// Corresponds to API responses and requests for Rails/JSON.`id` field to store the identifier
/// **seprarately** from the SwiftData id field.
/// - SwiftData.`id` is provided by the Swift.Misc.Identifiable protocol.
/// - The Rails.`id` field _MUST NOT COLLIDE_ with the SwiftData.`id` field.
// TODO: What to do about some ID results that are returned as Int (Organization) vs. String? (AuthenticatedUser, Bike)
protocol BikeIndexIdentifiable {
    var identifier: String { get }
}
