//
//  EditBikeRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

final class EditBikeRobot: Robot {
    lazy var viewBikeButton = app.links["View Bike"]

    @discardableResult
    func tapViewBikeButton() -> BikeDetailRobot {
        tap(viewBikeButton)

        return BikeDetailRobot(app)
    }
}
