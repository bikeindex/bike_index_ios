//
//  RegisterBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/9/25.
//

import Foundation

final class RegisterBikeRobot: Robot {
    lazy var goToOurSerialPage = app.links.matching(
        NSPredicate(format: "label == %@", "go to our serial page")
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
    func scrollToManufacturerTextView() -> Self {
        app.swipeUp()
        return self
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
