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
        app.launch()
        try signIn(app: app)

        // NOTE: Deeplinks will remove the second `:` from `bikeindex://https://bikeindex...`
        XCUIDevice.shared.system.open(stickerUrl)

        let stickerHeader = app.staticTexts["A40340"]
        _ = stickerHeader.waitForExistence(timeout: timeout)

        let unlinkedMessage: [XCUIElement] = [
            app.staticTexts["You scanned the sticker A 403 40, which is assigned to this bike."],
        ]
        for message in unlinkedMessage {
            _ = message.waitForExistence(timeout: timeout)
        }
    }

}
