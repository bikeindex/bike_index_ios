//
//  ContributorPlaces.swift
//  BikeIndex
//
//  Created by Jack on 10/19/25.
//

import Foundation

enum ContributorPlaces: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case pittsburgh = "Pittsburgh, PA"
    case portland = "Portland, OR"
    // for the backend
    case sf = "San Francisco, CA"

    case sheppey = "Isle of Sheppey, UK"

    /// At first access, randomized/shuffle all contributor places and store it
    /// in this static value to 1) give no preference to places and 2) keep the
    /// order consistent within this app launch.
    static let randomized = allCases.shuffled()
}
