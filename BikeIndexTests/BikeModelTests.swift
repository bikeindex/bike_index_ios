//
//  BikeModelTests.swift
//  BikeIndexTests
//
//  Created by Jack on 11/18/23.
//

import XCTest
import MapKit

final class BikeModelTests: XCTestCase {

    let sampleBikeJson = """
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

    /// Make sure that parsing a sample Bike from production works
    func testParsingModel() throws {
        let rawJsonData = sampleBikeJson.data(using: .utf8).unsafelyUnwrapped
        let output = try JSONDecoder().decode(Bike.self, from: rawJsonData)

        XCTAssertEqual(output.identifier, 20348)
        XCTAssertEqual(output.bikeDescription, "26 Giant Trance X  ")
        XCTAssertEqual(output.frameModel, "Trance X")
        XCTAssertEqual(output.typeOfCycle, .bike)
        XCTAssertEqual(output.frameColors, [.green, .blue])
        XCTAssertEqual(output.manufacturerName, "Giant")
        XCTAssertEqual(output.serial, "GS020355")

        XCTAssertEqual(output.status, .stolen)
        XCTAssertEqual(output.stolenCoordinates.distance(from: CLLocation(latitude: 45.53, longitude: -122.69)),
                       CLLocationDistance(integerLiteral: 0))
        XCTAssertEqual(output.dateStolen, Date(timeIntervalSince1970: 1376719200))

        XCTAssertNil(output.thumb)
        XCTAssertEqual(output.url, URL(string: "https://bikeindex.org/bikes/20348"))
        XCTAssertEqual(output.apiUrl, URL(string: "https://bikeindex.org/api/v1/bikes/20348"))
        XCTAssertEqual(output.publicImages, [])
    }

    /// Make sure that parsing JSON into a Bike model and encoding it back to JSON is idempotent.
    func testReadingAndWritingJson() throws {
        let rawJsonData = sampleBikeJson.data(using: .utf8).unsafelyUnwrapped
        let parsedModel = try JSONDecoder().decode(Bike.self, from: rawJsonData)

        let json = try JSONEncoder().encode(parsedModel)
        let modelString = String(data: json, encoding: .utf8).unsafelyUnwrapped

        XCTAssertEqual(sampleBikeJson, modelString)
    }
}

