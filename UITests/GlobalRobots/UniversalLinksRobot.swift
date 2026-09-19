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

    /// The scanned-sticker confirmation message. The site renders it as a single
    /// paragraph with the sticker code embedded in a <code> run, e.g.
    /// "You scanned the sticker BR 000 1, which is assigned to this bike."
    /// WebKit may expose this as one static text (label = the whole sentence) or as
    /// several runs, so we match on a distinctive substring rather than exact labels.
    /// This keeps the assertion resilient to the site rewording the sentence (which is
    /// exactly what broke the previous exact-match queries).
    private var unlinkedMessage: XCUIElement {
        app.webViews.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'assigned to this bike'")
        ).firstMatch
    }

    /// The embedded sticker code, rendered as a <code> element ("BR 000 1").
    private var stickerCode: XCUIElement {
        app.webViews.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'BR 000 1'")
        ).firstMatch
    }

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
        assert(stickerHeader, [.exists])

        return self
    }

    @discardableResult
    func checkUnlinkedMessage() -> Self {
        // Confirm the confirmation paragraph is present, then confirm the sticker code
        // is rendered within the page. Both use substring matches so the assertion
        // survives rewording of the surrounding prose.
        assert(unlinkedMessage, [.exists])
        assert(stickerCode, [.exists])

        return self
    }
}
