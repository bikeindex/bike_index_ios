//
//  RegisterStolenBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/9/25.
//

final class RegisterStolenBikeRobot: Robot {
    lazy var whatToDoButton = app.buttons["What to do if your bike is stolen"]
    lazy var whatToDoPageHeading = app.webViews.staticTexts["WHAT TO DO IF YOUR BIKE IS STOLEN"]

    lazy var howToButton = app.buttons["How to get your stolen bike back"]
    lazy var howToPageHeading = app.webViews.staticTexts["How to get your stolen bike back"]

    @discardableResult
    func checkWhatToDoPageLoads() -> Self {
        tap(whatToDoButton)
            .assert(whatToDoPageHeading, [.exists])
            .back()
    }

    @discardableResult
    func checkHowToPageLoads() -> Self {
        tap(howToButton)
            .assert(howToPageHeading, [.exists])
            .back()
    }
}
