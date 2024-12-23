//
//  ContentModel.swift
//  BikeIndex
//
//  Created by Jack on 12/22/24.
//

import SwiftUI
import SwiftData
import OSLog

final class ContentModel {

    @MainActor
    func fetchProfile(client: Client, modelContext: ModelContext) async {
        guard client.authenticated else {
            return
        }

        let fetch_v3_me = await client.api.get(Me.`self`)

        switch fetch_v3_me {
        case .success(let success):
            guard let myProfileSource = success as? AuthenticatedUserResponse else {
                Logger.model.debug("ContentController.fetchProfile failed to parse profile from \(String(reflecting: success), privacy: .public)")
                return
            }

            let myProfile = myProfileSource.modelInstance()
            myProfile.user = myProfileSource.user.modelInstance()

            do {
                modelContext.insert(myProfile)
                try? modelContext.save()
            }

            let myBikeIdentifiers = myProfileSource.bike_ids
            let predicate = #Predicate<Bike> { model in
                myBikeIdentifiers.contains(model.identifier)
            }
            let descriptor = FetchDescriptor<Bike>(predicate: predicate)

            do {
                let bikes = try modelContext.fetch(descriptor)
                bikes.forEach {
                    $0.authenticatedOwner = myProfile
                    $0.owner = myProfile.user
                }
                myProfile.bikes = bikes

                try? modelContext.save()
            } catch {
                Logger.model.debug("Attempting to associate AuthenticatedUser.bike_ids with bikes on disk but failed to find any. Using identifiers: \(myBikeIdentifiers)")
            }

        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
        }
    }

    @MainActor
    func fetchBikes(client: Client, modelContext: ModelContext) async {
        guard client.authenticated else {
            return
        }

        let fetchMyBikes = await client.api.get(Me.bikes)

        switch fetchMyBikes {
        case .success(let success):
            guard let myBikesSource = success as? MultipleBikeResponseContainer else {
                Logger.model.debug("ContentController.fetchBikes failed to parse bikes from \(String(reflecting: success), privacy: .public)")
                return
            }

            do {
                for bike in myBikesSource.bikes {
                    let model = bike.modelInstance()
                    modelContext.insert(model)
                }

                try? modelContext.save()
            }

        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
        }
    }
}
