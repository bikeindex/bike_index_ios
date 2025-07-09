//
//  RegisterBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/9/25.
//

import Foundation

final class RegisterBikeRobot: Robot {
    lazy var goToOurSerialPage = app.staticTexts.matching(
        NSPredicate(format: "label BEGINSWITH %@", "Every bike has a unique")
    ).element
    lazy var serialPageHeading = app.webViews.staticTexts["BIKE SERIAL NUMBERS"]

    @discardableResult
    func tapGoToOurSerialPage() -> Self {
        tap(goToOurSerialPage)
    }

    @discardableResult
    func checkSerialPageLoaded() -> Self {
        assert(serialPageHeading, [.exists])
    }
}
