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
    lazy var manufacturerTextField = app.textFields["manufacturerSearchTextField"]

    @discardableResult
    func tapGoToOurSerialPage() -> Self {
        tap(goToOurSerialPage)
    }

    @discardableResult
    func checkSerialPageLoaded() -> Self {
        assert(serialPageHeading, [.exists])
    }

    @discardableResult
    func tapManufacturerTextField() -> Self {
        tap(manufacturerTextField)
    }

    @discardableResult
    func typeIntoManufacturerTextField(_ text: String) -> Self {
        manufacturerTextField.typeText(text)
        return self
    }

    @discardableResult
    func checkManufacturerTextFieldContains(text: String) -> Self {
        assert(manufacturerTextField, [.containsValue(text)])
    }
}
