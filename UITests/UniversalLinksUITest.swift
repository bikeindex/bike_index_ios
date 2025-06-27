//
//  UniversalLinksUITest.swift
//  UITests
//
//  Created by Jack on 4/5/25.
//

import OSLog
import XCTest

let stickerUrl = URL(string: "bikeindex://https://bikeindex.org/bikes/scanned/A40340")!

// MARK: - UniversalLinksUITest
extension BikeIndexUITests {

    /// Sometimes this fails when a page plainly fails to load, may need to add more resiliency.
    func test_authenticated_bikes_scanned_id_universal_link() throws {
        XCTAssert(false)
//        try UniversalLinksRobot(app: app, testCase: self)
//            .startWithSignIn()
//            .openLink()
//            .checkStickerHeader()
//            .checkUnlinkedMessage()
    }

}
