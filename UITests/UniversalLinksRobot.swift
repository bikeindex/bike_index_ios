//
//  UniversalLinksRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/21/25.
//

import XCUIAutomation

final class UniversalLinksRobot: Robot {
    private lazy var stickerHeader = app.staticTexts["A40340"]
    private lazy var unlinkedMessage: [XCUIElement] = [
        app.staticTexts["You scanned the sticker A 403 40, which is assigned to this bike."]
    ]

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
