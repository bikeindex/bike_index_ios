//
//  MainContent.swift
//  BikeIndex
//
//  Created by Jack on 12/31/23.
//

import Foundation

enum MainContent: Identifiable {
    var id: Self { self }

    //
    case settings

    //
    case registerBike
    case lostBike

    //
    case searchBikes
}
