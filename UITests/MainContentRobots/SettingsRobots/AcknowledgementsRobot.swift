//
//  AcknowledgementsRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/7/25.
//

final class AcknowledgementsRobot: Robot, NavigatesBackToSettings {
    lazy var iOS_repo = app.collectionViews.cells.element(boundBy: 2)
    lazy var linkButton = app.buttons["Open Repository"]

    @discardableResult
    func tap_iOS_repo() -> Self {
        tap(iOS_repo)
    }

    @discardableResult
    func tapLinkButton() -> WebViewRobot {
        tap(linkButton)

        return WebViewRobot(app)
    }
}
