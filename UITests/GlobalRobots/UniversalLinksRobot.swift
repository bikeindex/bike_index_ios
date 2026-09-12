//
//  UniversalLinksRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/21/25.
//

import XCTest
import XCUIAutomation

final class UniversalLinksRobot: Robot {
    let timeout: TimeInterval = 45
    private lazy var stickerHeader = app.navigationBars.staticTexts["BR 000 1"]
    private lazy var unlinkedMessage: [XCUIElement] = [
        app.webViews.staticTexts["You scanned the sticker"],
        app.webViews.staticTexts["BR 000 1"],
        app.webViews.staticTexts[", which is assigned to this bike."],
    ]

    private func stickerUrl() throws -> URL {
        // Configure these values in Test-credentials.xcconfig (see adjacent template file)
        let config = try APIConfiguration.uiTestConfig()
        return URL(string: "bikeindex://\(config.host)/bikes/scanned/BR0001")!
    }

    @discardableResult
    func openLink() throws -> Self {
        // NOTE: Deeplinks will remove the second `:` from `bikeindex://https://bikeindex...`
        XCUIDevice.shared.system.open(try stickerUrl())

        return self
    }

    @discardableResult
    func checkStickerHeader() -> Self {
        assert(stickerHeader, [.exists], timeout: timeout)

        return self
    }

    @discardableResult
    func checkUnlinkedMessage() -> Self {
        for message in unlinkedMessage {
            assert(message, [.exists], timeout: timeout)
        }

        return self
    }
}
