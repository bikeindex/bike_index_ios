//
//  MainContentPage+ViewModel+GroupMode.swift
//  BikeIndex
//
//  Created by Jack on 3/22/25.
//
import SwiftUI

extension MainContentPage.ViewModel {
    enum GroupMode: CaseIterable, Identifiable {
        case byStatus
        case byManufacturer

        var id: Self { self }

        var displayName: String {
            switch self {
            case .byStatus:
                return "Status"
            case .byManufacturer:
                return "Manufacturer"
            }
        }
    }
}
