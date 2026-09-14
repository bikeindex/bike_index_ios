//
//  BikeDetailRobot.swift
//  BikeIndex
//
//  Created by Milo Wyner on 7/2/25.
//

/// Control app behavior around the ``BikeDetailWebView`` SwiftUI controls
/// and in the future, ``BikeDetailOfflineView``.
final class BikeDetailRobot: Robot {
    lazy var editButton = app.buttons["Edit"]

    @discardableResult
    func tapEditButton() -> EditBikeRobot {
        tap(editButton)

        return EditBikeRobot(app)
    }
}
