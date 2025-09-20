//
//  UniversalLinksRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/21/25.
//

import XCUIAutomation

final class UniversalLinksRobot: Robot {
    private lazy var stickerHeader = app.navigationBars.staticTexts["A 403 40"]
    private lazy var unlinkedMessage: [XCUIElement] = [
        app.webViews.staticTexts["You scanned the sticker"],
        app.webViews.staticTexts["A 403 40"],
        app.webViews.staticTexts[", which is assigned to this bike."],
    ]
    private let stickerUrl = URL(string: "bikeindex://https://bikeindex.org/bikes/scanned/A40340")!

    @discardableResult
    func openLink() -> Self {
        // NOTE: Deeplinks will remove the second `:` from `bikeindex://https://bikeindex...`
        XCUIDevice.shared.system.open(stickerUrl)

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
