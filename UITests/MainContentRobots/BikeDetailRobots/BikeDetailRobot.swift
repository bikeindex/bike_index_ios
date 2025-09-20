//
//  BikeDetailRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class BikeDetailRobot: Robot {
    lazy var editButton = app.buttons["Edit"]

    @discardableResult
    func tapEditButton() -> EditBikeRobot {
        tap(editButton)

        return EditBikeRobot(app)
    }
}
