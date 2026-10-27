//
//  BikeDetailView+ViewModel.swift
//  BikeIndex
//
//  Created by Jack on 12/13/25.
//

import Foundation
import HoneybadgerSwift
import OSLog
import SwiftData

extension BikeDetailWebView {
    @Observable
    class ViewModel {
        /// 1. Fetch the full bike page for a specific bike id
        /// 2. Fetch the current user's list of bikes
        ///     - Filter out the full detail bike if it changed ownership
        ///     - Re-link full detail bike to current ownership
        /// This could guard too strongly against stale data but the other
        /// benefit is affirming the current user's list of bikes contains this
        /// one.
        /// Note: This fails shut / exits early for non-owned bikes. Any future
        /// ability to view others' bikes will need refinements here.
        @MainActor
        func fetchFullBikeDetails(
            client: Client, modelContext: ModelContext, _ bikeId: Bike.BikeIdentifier
        ) async {
            guard client.authenticated else { return }

            async let fetch_v3_get_bike_id = client.get(Bikes.bikes(identifier: bikeId))
            async let fetch_v3_get_my_bikes = client.get(Me.bikes)

            switch (await fetch_v3_get_bike_id, await fetch_v3_get_my_bikes) {
            case (.success(let getBikeIdResponse), .success(let myBikesResponse)):
                guard let fullBikeContainer = getBikeIdResponse as? FullBikeResponseContainer else {
                    Logger.model.debug(
                        "\(type(of: self)).\(#function) failed to parse bike from \(String(reflecting: getBikeIdResponse), privacy: .public)"
                    )
                    return
                }

                guard let myBikesContainer = myBikesResponse as? MultipleBikeResponseContainer
                else {
                    Logger.model.debug(
                        "\(type(of: self)).\(#function) failed to parse my bikes from \(String(reflecting: myBikesResponse), privacy: .public)"
                    )
                    return
                }

                let fullBike = fullBikeContainer.bike.modelInstance()
                let myIdentifiers = myBikesContainer.bikes.compactMap(\.id)
                guard myIdentifiers.contains(fullBike.identifier) else {
                    Logger.model.error(
                        "\(type(of: self)).\(#function)) [exiting function] attempted to fetch FULL bike but it is not in this user's list of bikes. from \(String(reflecting: myBikesResponse), privacy: .public) - \(String(reflecting: getBikeIdResponse), privacy: .public)"
                    )
                    return
                }

                Logger.model.debug(
                    "\(type(of: self)).\(#function)) found FULL bike from \(String(reflecting: getBikeIdResponse), privacy: .public) containing created=\(String(describing: fullBike.createdAt?.description)))/updated=\(String(describing: fullBike.updatedAt))"
                )

                do {
                    try modelContext.transaction {
                        let ownerResults = try modelContext.fetch(
                            FetchDescriptor(predicate: #Predicate<AuthenticatedUser> { _ in true }))
                        assert(ownerResults.count == 1)
                        guard let owner = ownerResults.first else {
                            return
                        }

                        fullBike.authenticatedOwner = owner
                        fullBike.owner = owner.user
                        modelContext.insert(fullBike)
                    }
                } catch {
                    Honeybadger.notify(error: error, bikeId: bikeId)
                    Logger.model.error(
                        "\(type(of: self)).\(#function) - Writing Bike failed with \(error) - \(String(reflecting: getBikeIdResponse))"
                    )
                }

                assert(fullBike.owner != nil)
            case (.failure(let getBikeIdFailure), _):
                Logger.model.error(
                    "\(type(of: self)).\(#function) - Need both /v3/bikes/:id and /v3/me/bikes to succeed - Failed with \(getBikeIdFailure)."
                )
            case (_, .failure(let getMyBikesFailure)):
                Logger.model.error(
                    "\(type(of: self)).\(#function) - Need both /v3/bikes/:id and /v3/me/bikes to succeed - Failed with \(getMyBikesFailure)"
                )
            }
        }
    }
}
