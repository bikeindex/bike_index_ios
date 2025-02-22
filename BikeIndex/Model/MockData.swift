//
//  MockData.swift
//  UnitTests
//
//  Created by Jack on 11/26/23.
//

import Foundation

#if !RELEASE
struct MockData {
    static let fullToken =
"""
{
    "access_token": "vQclXy6QL-OZJnYP88mpjGJXiK8KkwHwCrpMDezLedY",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "-Y8FDaHbr3F6KauqtFINsPvIjziN9DCIbdGEy8GS-tM",
    "scope": "read_user write_user read_bikes write_bikes read_organization_membership write_organizations",
    "created_at": 1698883930
}
"""

    static let userJson =
"""
{
    "username": "00d66fc4724cad",
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
    "id": "456654",
    "user": \(userJson),
    "bike_ids": [

    ],
    "memberships": [
        {
            "organization_name": "Test account",
            "organization_slug": "testers",
            "organization_id": 1234,
            "organization_access_token": "59658bae53dec4cced6eafee0abc9670",
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
 "propulsion_type_slug": "foot-pedal",
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
#endif
