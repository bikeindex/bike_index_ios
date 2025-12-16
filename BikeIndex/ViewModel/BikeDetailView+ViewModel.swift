//
//  BikeDetailView+ViewModel.swift
//  BikeIndex
//
//  Created by Jack on 12/13/25.
//

import Foundation
import OSLog
import SwiftData

extension BikeDetailWebView {
    @Observable
    class ViewModel {
        @MainActor
        func fetchFullBikeDetails(
            client: Client, modelContext: ModelContext, _ bikeId: Bike.BikeIdentifier
        ) async {
            guard client.authenticated else { return }

            let fetch_v3_get_bike_id = await client.get(Bikes.bikes(identifier: bikeId))

            switch fetch_v3_get_bike_id {
            case .success(let success):
                guard let container = success as? RegisterBikeResponseContainer else {
                    Logger.model.debug(
                        "\(type(of: self)).\(#function) failed to parse bike from \(String(reflecting: success), privacy: .public)"
                    )
                    return
                }

                let fullBike = container.bike.modelInstance()
                Logger.model.debug(
                    "\(type(of: self)).#function) found FULL bike from \(String(reflecting: success), privacy: .public) containing created=\(String(describing: fullBike.createdAt?.description)))/updated=\(String(describing: fullBike.updatedAt))"
                )

                do {
                    try modelContext.transaction {
                        modelContext.insert(fullBike)
                    }
                } catch {
                    Logger.model.error(
                        "\(type(of: self)).\(#function) - Writing Bike failed with \(error) - \(String(reflecting: success))"
                    )
                }
            case .failure(let failure):
                Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
            }
        }
    }
}
