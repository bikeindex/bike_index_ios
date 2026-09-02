//
//  UniversalLinksRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/21/25.
//

import XCTest
import XCUIAutomation

final class UniversalLinksRobot: Robot {
    private lazy var stickerHeader = app.navigationBars.staticTexts["BR 000 1"]
    private lazy var unlinkedMessage: [XCUIElement] = [
        app.webViews.staticTexts["You scanned the sticker"],
        app.webViews.staticTexts["BR0001"],
        app.webViews.staticTexts[", which is assigned to this bike."],
    ]

    private func stickerUrl() throws -> URL {
        // Configure these values in Test-credentials.xcconfig (see adjacent template file)
        let uiTestBundle = try XCTUnwrap(Bundle.uiTests)
        let infoDictionary = try XCTUnwrap(uiTestBundle.infoDictionary)

        let hostString = try XCTUnwrap(
            (infoDictionary["API_HOST"] as? String)?
                .replacing("\\/\\/", with: "//")
        )
        var host = try XCTUnwrap(URL(string: hostString))
        let portString = try XCTUnwrap(infoDictionary["API_PORT"] as? String)
        let port = try XCTUnwrap(UInt16(portString))

        if port != 443 {
            host = try XCTUnwrap(URL(string: hostString + ":\(port)"))
        }

        return URL(string: "bikeindex://\(host)/bikes/scanned/BR0001")!
    }

    @discardableResult
    func openLink() throws -> Self {
        // NOTE: Deeplinks will remove the second `:` from `bikeindex://https://bikeindex...`
        XCUIDevice.shared.system.open(try stickerUrl())

        return self
    }

    @discardableResult
    func checkStickerHeader() -> Self {
        assert(stickerHeader, [.exists])

        return self
    }

    @discardableResult
    func checkUnlinkedMessage() -> Self {
        for message in unlinkedMessage {
            assert(message, [.exists])
        }

        return self
    }
}
