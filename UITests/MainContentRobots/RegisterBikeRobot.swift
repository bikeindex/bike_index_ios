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
    lazy var photoUploadHeader = app.staticTexts["photoUploadHeader"]
    lazy var emailTextField = app.textFields["ownerEmailTextField"]

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

    @discardableResult
    func scrollToOwnerEmailTextField() -> Self {
        while emailTextField.exists == false {
            app.swipeUp(velocity: .fast)
        }
        return self
    }

    /// Redact the auto-filled email text field value.
    /// iPad screenshots have enough space to display the email and we want to
    /// omit that from App Store screenshots.
    @discardableResult
    func redactAutofillEmail() -> Self {
        while emailTextField.value as? String != "Who owns this bike?" {
            let deleteButton = app.buttons["delete.left"].firstMatch
            if deleteButton.waitForExistence(timeout: 1) {
                deleteButton.tap()
            }
        }
        return self
    }

    @discardableResult
    func scrollToTop() -> Self {
        while photoUploadHeader.exists == false {
            app.swipeDown(velocity: .fast)
        }
        return self
    }
}
