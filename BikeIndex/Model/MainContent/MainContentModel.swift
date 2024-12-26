//
//  MainContentModel.swift
//  BikeIndex
//
//  Created by Jack on 12/22/24.
//

import SwiftUI
import SwiftData
import OSLog

final class MainContentModel {

    @MainActor
    func fetchProfile(client: Client, modelContext: ModelContext) async throws(Error) {
        guard client.authenticated else {
            return
        }

        let fetch_v3_me = await client.api.get(Me.`self`)

        switch fetch_v3_me {
        case .success(let success):
            guard let myProfileSource = success as? AuthenticatedUserResponse else {
                Logger.model.debug("ContentController.fetchProfile failed to parse profile from \(String(reflecting: success), privacy: .public)")
                throw Error.failed(message: "Failed to parse fetched profile.")
            }

            let myProfile = myProfileSource.modelInstance()
            myProfile.user = myProfileSource.user.modelInstance()

            // 1. Write the AuthenticatedUser
            // 2. Write the User
            // 3. Find any cached bikes known-to-be-owned by this user and link them.
            do {
                try modelContext.transaction {
                    modelContext.insert(myProfile)
                    if let user = myProfile.user {
                        modelContext.insert(user)
                    }

                    let myBikeIdentifiers = myProfileSource.bike_ids
                    let predicate = #Predicate<Bike> { model in
                        myBikeIdentifiers.contains(model.identifier)
                    }
                    let descriptor = FetchDescriptor<Bike>(predicate: predicate)

                    let bikes = try modelContext.fetch(descriptor)
                    bikes.forEach {
                        $0.authenticatedOwner = myProfile
                        $0.owner = myProfile.user
                    }
                    myProfile.bikes = bikes
                }
            } catch (let swiftError) {
                throw Error.swiftError(swiftError)
            }
        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
            throw Error.swiftError(failure)
        }
    }

    @MainActor
    func fetchBikes(client: Client, modelContext: ModelContext) async throws(Error) {
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
                try modelContext.transaction {
                    // TODO: Look up bikes by identifier (distinct from SwiftData.id)
                    for bike in myBikesSource.bikes {
                        let model = bike.modelInstance()
                        modelContext.insert(model)
                    }
                }
            } catch (let swiftError) {
                throw Error.swiftError(swiftError)
            }

        case .failure(let failure):
            Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
        }
    }
}
