//
//  EditBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

import Foundation
import XCTest

/// Control app behavior for web-based content within ``BikeDetailWebView``.
final class EditBikeRobot: Robot {
    lazy var viewBikeButton = app.links["View Bike"]
    lazy var transferButton = app.links["Transfer, Hide or Delete"]
    lazy var ownerEmailTextField = app.textFields["Owner email"].firstMatch
    lazy var updateOwnershipButton = app.buttons["Update ownership"]

    /// Return control to app-based behavior
    @discardableResult
    func tapViewBikeButton() -> BikeDetailRobot {
        tap(viewBikeButton)

        return BikeDetailRobot(app)
    }

    // MARK: Web view content internal

    @discardableResult
    func scrollToFooter() -> Self {
        // TODO: Scroll until transfer button is visible
        while transferButton.isHittable == false {
            app.swipeUp(velocity: .fast)
        }
        assert(transferButton, [.isEnabled])
        return self
    }

    @discardableResult
    func tapTransferHideOrDelete() -> Self {
        tap(transferButton)
        return self
    }

    /// Alternate approach to clearing native textfield available in ``RegisterBikeRobot/redactAutofillEmail``.
    @discardableResult
    func typeNewOwner(email: String) -> Self {
        tap(ownerEmailTextField)
        // triple-tap to select _all_ text for replacement.
        // (single tap goes up to special characters but stops).
        ownerEmailTextField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        ownerEmailTextField.typeText(email)
        XCTAssertEqual(ownerEmailTextField.value as? String, email)
        return self
    }

    @discardableResult
    func updateOwnership() -> Self {
        tap(updateOwnershipButton)
        return self
    }

    @discardableResult
    func back() -> MainContentRobot {
        tap(navigationBarButton, timeout: Robot.defaultTimeout)
        return MainContentRobot(app)
    }
}
