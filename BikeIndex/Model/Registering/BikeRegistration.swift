//
//  BikeRegistration.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation

struct BikeRegistration: Encodable {
    struct Serial {
        static let unknown = "unkown"
    }

    // MARK: Required fields
    let serial: String
    let manufacturer: String
    let owner_email: String
    /// Write to `color` field in addition to `primary_frame_color`
    let color: String
    let primary_frame_color: String

    let test = true

    // MARK: Optional fields
    var owner_email_is_phone_number: Bool?
    var organization_slug: String?
    var cycle_type_name: BicycleType?
    var no_duplicate: Bool?
    var rear_wheel_bsd: Int?
    var rear_tire_narrow: Bool?
    var front_wheel_bsd: String?
    var front_tire_narrow: Bool?
    var frame_model: String?
    var year: UInt?
    var description: String?
    var secondary_frame_color: String?
    var tertiary_frame_color: String?
    var rear_gear_type_slug: String?
    var front_gear_type_slug: String?
    var extra_registration_number: String?
    var handlebar_type_slug: String?
    var no_notify: Bool?
    var is_for_sale: Bool?
    var frame_material: String? // replace with frame material enum?
    var external_image_urls: [URL]?
    var bike_sticker: String?
    var propulsion_type_slug: String?
    var stolen_record: StolenRecord?
    var components: [Component]?

    init(serial: String?, manufacturer: String, owner_email: String, primary_frame_color: FrameColor, owner_email_is_phone_number: Bool? = nil, organization_slug: String? = nil, cycle_type_name: BicycleType? = nil, no_duplicate: Bool? = nil, rear_wheel_bsd: Int? = nil, rear_tire_narrow: Bool? = nil, front_wheel_bsd: String? = nil, front_tire_narrow: Bool? = nil, frame_model: String? = nil, year: UInt? = nil, description: String? = nil, secondary_frame_color: FrameColor? = nil, tertiary_frame_color: FrameColor? = nil, rear_gear_type_slug: String? = nil, front_gear_type_slug: String? = nil, extra_registration_number: String? = nil, handlebar_type_slug: String? = nil, no_notify: Bool? = nil, is_for_sale: Bool? = nil, frame_material: String, external_image_urls: [URL]? = nil, bike_sticker: String? = nil, propulsion_type_slug: String? = nil, stolen_record: StolenRecord? = nil, components: [Component]? = nil) {
        self.serial = serial ?? Serial.unknown
        self.manufacturer = manufacturer
        self.owner_email = owner_email
        self.primary_frame_color = primary_frame_color.rawValue.lowercased()
        self.color = primary_frame_color.rawValue.lowercased()
        self.owner_email_is_phone_number = owner_email_is_phone_number
        self.organization_slug = organization_slug
        self.cycle_type_name = cycle_type_name
        self.no_duplicate = no_duplicate
        self.rear_wheel_bsd = rear_wheel_bsd
        self.rear_tire_narrow = rear_tire_narrow
        self.front_wheel_bsd = front_wheel_bsd
        self.front_tire_narrow = front_tire_narrow
        self.frame_model = frame_model
        self.year = year
        self.description = description
        self.secondary_frame_color = secondary_frame_color?.rawValue.lowercased()
        self.tertiary_frame_color = tertiary_frame_color?.rawValue.lowercased()
        self.rear_gear_type_slug = rear_gear_type_slug
        self.front_gear_type_slug = front_gear_type_slug
        self.extra_registration_number = extra_registration_number
        self.handlebar_type_slug = handlebar_type_slug
        self.no_notify = no_notify
        self.is_for_sale = is_for_sale
        self.frame_material = frame_material
        self.external_image_urls = external_image_urls
        self.bike_sticker = bike_sticker
        self.propulsion_type_slug = propulsion_type_slug
        self.stolen_record = stolen_record
        self.components = components
    }

    init(bike: Bike, mode: RegisterMode, stolen: StolenRecord?, ownerEmail: String) {
        // If the serial number is absent then continue with a constant
        self.serial = bike.serial ?? Serial.unknown

        // Required fields
        self.manufacturer = bike.manufacturerName
        self.primary_frame_color = bike.frameColorPrimary.rawValue.lowercased()
        self.color = bike.frameColorPrimary.rawValue.lowercased()
        self.owner_email = ownerEmail // Bike<->User relationships are not yet established

        // Non-required fields
        self.secondary_frame_color = bike.frameColorSecondary?.rawValue.lowercased()
        self.tertiary_frame_color = bike.frameColorTertiary?.rawValue.lowercased()

        self.cycle_type_name = bike.typeOfCycle
        if let bikeYear = bike.year {
            self.year = UInt(bikeYear)
        }
        self.frame_model = bike.frameModel

        if mode == .myStolenBike {
            self.stolen_record = stolen
        } else {
            self.stolen_record = nil
        }

        // Unsupported fields for future work
        self.owner_email_is_phone_number = nil
        self.organization_slug = nil
        self.cycle_type_name = nil
        self.no_duplicate = nil
        self.rear_wheel_bsd = nil
        self.rear_tire_narrow = nil
        self.front_wheel_bsd = nil
        self.front_tire_narrow = nil
        self.frame_model = nil
        self.description = nil
        self.rear_gear_type_slug = nil
        self.front_gear_type_slug = nil
        self.extra_registration_number = nil
        self.handlebar_type_slug = nil
        self.no_notify = nil
        self.is_for_sale = nil
        self.frame_material = nil
        self.external_image_urls = nil
        self.bike_sticker = nil
        self.propulsion_type_slug = nil
        self.components = nil
    }
}

struct Component: Encodable {
    let manufacturer: String
    let component_type:	String // replace with component-type / ctype enum
    let model: String
    let year: Int
    let description: String
    let serial: String
    let front_or_rear: String
}
