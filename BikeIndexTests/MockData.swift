//
//  MockData.swift
//  BikeIndexTests
//
//  Created by Jack on 11/26/23.
//

import Foundation

struct MockData {
    static let userJson =
"""
{
    "username": "d16b16aea831b",
    "name": "Test User",
    "email": "test@example.com",
    "secondary_emails": [],
    "twitter": null,
    "created_at": 1694235377,
    "image": null
}
"""

    static let authenticatedUserJson =
"""
{
    "id": "591441",
    "user": \(userJson),
    "bike_ids": [

    ],
    "memberships": [
        {
            "organization_name": "Hogwarts School of Witchcraft and Wizardry",
            "organization_slug": "hogwarts",
            "organization_id": 818,
            "organization_access_token": "bdcc3c3c85716167ce566ab1418ab13b",
            "user_is_organization_admin": true
        }
    ]
}
"""

    static let sampleBikeJson = """
{
 "date_stolen": 1376719200,
 "description": "26 Giant Trance X  ",
 "frame_colors": [
   "Green",
   "Blue"
 ],
 "frame_model": "Trance X",
 "id": 20348,
 "is_stock_img": false,
 "large_img": null,
 "location_found": null,
 "manufacturer_name": "Giant",
 "external_id": null,
 "registry_name": null,
 "registry_url": null,
 "serial": "GS020355",
 "status": "stolen",
 "stolen": true,
 "stolen_coordinates": [
   45.53,
   -122.69
 ],
 "stolen_location": "Portland, OR 97209, US",
 "thumb": null,
 "title": "2012 Giant Trance X",
 "url": "https://bikeindex.org/bikes/20348",
 "year": 2012,
 "propulsion_type_slug": "foot-pedal",
 "cycle_type_slug": "bike",
 "registration_created_at": 1377151200,
 "registration_updated_at": 1585269739,
 "api_url": "https://bikeindex.org/api/v1/bikes/20348",
 "manufacturer_id": 153,
 "paint_description": null,
 "name": null,
 "frame_size": null,
 "rear_tire_narrow": true,
 "front_tire_narrow": null,
 "type_of_cycle": "Bike",
 "test_bike": false,
 "rear_wheel_size_iso_bsd": null,
 "front_wheel_size_iso_bsd": null,
 "handlebar_type_slug": null,
 "frame_material_slug": null,
 "front_gear_type_slug": null,
 "rear_gear_type_slug": null,
 "extra_registration_number": null,
 "additional_registration": null,
 "stolen_record": {
   "date_stolen": 1376719200,
   "location": "Portland, OR 97209, US",
   "latitude": 45.53,
   "longitude": -122.69,
   "theft_description": "Bike rack Reward: Tbd",
   "locking_description": null,
   "lock_defeat_description": null,
   "police_report_number": "1368801",
   "police_report_department": "Portland",
   "created_at": 1402778082,
   "create_open311": false,
   "id": 16690
 },
 "public_images": [],
 "components": []
}
"""

}
