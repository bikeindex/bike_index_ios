//
//  MainContent+ViewModel.swift
//  BikeIndex
//
//  Created by Jack on 12/22/24.
//

import OSLog
import SwiftData

extension MainContentPage {
    /// Model for ``MainContentPage`` to perform helpful work retrieving and serializing.
    /// Performs all work on the MainActor so this may be view-blocking
    /// Consider moving this to @ModelActor
    /// - https://www.massicotte.org/model-actor
    /// - https://fatbobman.com/en/posts/concurret-programming-in-swiftdata/
    final class ViewModel {

        /// Fetch the current user's profile. Must be authenticated already!
        /// Will perform these steps:
        /// 0. Destroy all other authenticated users
        /// 1. Write this ``AuthenticatedUser``
        /// 2. Write the User
        /// 3. Find any cached bikes known-to-be-owned by this user and link them.
        /// Wrapped Swift.Error can be thrown from A) network operations and B) SwiftData operations.
        /// MainContentModel.Error can be thrown from C) application state errors or D) application logic errors.
        /// - Parameter client: App network Client to perform network requests.
        /// - Parameter modelContext: SwiftData modelContext to do work on
        /// - Throws: MainContentModel.Error
        @MainActor
        func fetchProfile(client: Client, modelContext: ModelContext) async throws(ViewModel.Error)
        {
            guard client.authenticated else {
                return
            }

            let fetch_v3_me = await client.api.get(Me.`self`)

            switch fetch_v3_me {
            case .success(let success):
                guard let myProfileSource = success as? AuthenticatedUserResponse else {
                    Logger.model.debug(
                        "ContentController.fetchProfile failed to parse profile from \(String(reflecting: success), privacy: .public)"
                    )
                    throw Error.failed(message: "Failed to parse fetched profile.")
                }

                let myProfile = myProfileSource.modelInstance()
                myProfile.user = myProfileSource.user.modelInstance()

                do {
                    try modelContext.transaction {
                        // 0.
                        let knownGoodId = myProfileSource.id
                        let inactiveAuthUserPredicate = #Predicate<AuthenticatedUser> { model in
                            model.identifier != knownGoodId
                        }
                        try modelContext.delete(
                            model: AuthenticatedUser.self, where: inactiveAuthUserPredicate)

                        // 1. and 2.
                        modelContext.insert(myProfile)
                        if let user = myProfile.user {
                            modelContext.insert(user)
                        }

                        // 3.
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

        /// Fetch the current user's bikes. Must be authenticated already! Must have an AuthenticatedUser already!
        /// Will fetch and associate bikes with ``Bike/owner`` and ``Bike/authenticatedOwner``.
        /// Wrapped Swift.Error can be thrown from A) network operations and B) SwiftData operations.
        /// MainContentModel.Error can be thrown from C) application state errors or D) application logic errors.
        /// - Parameter client: App network Client to perform network requests.
        /// - Parameter modelContext: SwiftData modelContext to do work on
        /// - Throws: MainContentModel.Error
        @MainActor
        func fetchBikes(client: Client, modelContext: ModelContext) async throws(ViewModel.Error) {
            guard client.authenticated else {
                return
            }

            let fetchMyBikes = await client.api.get(Me.bikes)

            switch fetchMyBikes {
            case .success(let success):
                guard let myBikesSource = success as? MultipleBikeResponseContainer else {
                    Logger.model.debug(
                        "ContentController.fetchBikes failed to parse bikes from \(String(reflecting: success), privacy: .public)"
                    )
                    throw Error.failed(message: "Failed to parse fetched bikes.")
                }

                do {
                    try modelContext.transaction {
                        let ownerResults = try modelContext.fetch(
                            FetchDescriptor(predicate: #Predicate<AuthenticatedUser> { _ in true }))
                        assert(ownerResults.count == 1)
                        guard let owner = ownerResults.first else {
                            throw Error.failed(message: "Failed to fetch authenticated user.")
                        }

                        for bike in myBikesSource.bikes {
                            let model = bike.modelInstance()
                            model.authenticatedOwner = owner
                            model.owner = owner.user
                            modelContext.insert(model)
                        }
                    }
                } catch (let swiftError) {
                    throw Error.swiftError(swiftError)
                }

            case .failure(let failure):
                Logger.model.error("\(type(of: self)).\(#function) - Failed with \(failure)")
                throw Error.swiftError(failure)
            }
        }
    }
}
