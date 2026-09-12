//
//  MainContentViewModelTests.swift
//  UnitTests
//
//  Created by Jack on 9/6/26.
//

import Foundation
import SwiftData
import Testing

@testable import BikeIndex

/// Tests for the "clean stale bikes" behavior in `MainContentPage.ViewModel`.
///
/// When a user's profile is fetched, locally-stored `Bike` models owned by the
/// current user but whose `identifier` is not in the profile's `bike_ids` list
/// have their `Bike.owner` set to `nil`. Bikes owned by other users must remain
/// untouched.
///
/// The `Client` is a concrete class and `fetchProfile` calls `client.get(...)`
/// directly, so we cannot easily stub the network layer in unit tests. Instead,
/// we test the exact stale-bike predicate + mutation logic used by
/// `fetchProfile` in isolation, and we verify `fetchProfile`'s guard behavior
/// (authenticated / unauthenticated) separately.
@MainActor
struct MainContentViewModelTests {

    // MARK: - Helpers

    /// Build an in-memory ModelContainer configured for the models used in these tests.
    private func makeContainer(name: String) throws -> ModelContainer {
        let config = ModelConfiguration(
            name, isStoredInMemoryOnly: true, allowsSave: true)
        let container = try ModelContainer(
            for: AuthenticatedUser.self, User.self, Bike.self,
            configurations: config
        )
        container.mainContext.autosaveEnabled = false
        return container
    }

    /// Create and insert a Bike model with the given identifier into the context.
    private func makeBike(id: Int, context: ModelContext) throws -> Bike {
        let bike = Bike(
            identifier: id,
            title: "Bike \(id)",
            primaryColor: .black,
            manufacturerName: "Test",
            typeOfCycle: .bike,
            typeOfPropulsion: .footPedal,
            status: .withOwner,
            stolenCoordinateLatitude: 0,
            stolenCoordinateLongitude: 0,
            url: URL(string: "https://bikeindex.org/bikes/\(id)")!,
            publicImages: []
        )
        context.insert(bike)
        return bike
    }

    /// Create and insert a User model.
    private func makeUser(
        email: String, username: String, name: String, context: ModelContext
    ) throws -> User {
        let user = User(
            email: email, username: username, name: name,
            additionalEmails: [], createdAt: Date(), bikes: []  // TODO: fixup
        )
        context.insert(user)
        return user
    }

    /// Build an in-memory container pre-populated with:
    ///   - `currentOwner` (email: "current@example.com")
    ///   - `otherOwner` (email: "other@example.com")
    ///   - Bikes owned by `currentOwner`: ids 1, 2, 3
    ///   - Bikes owned by `otherOwner`: ids 10, 11, 12
    private func makePrepopulatedContainer(name: String) throws -> (
        container: ModelContainer,
        currentOwner: User,
        otherOwner: User
    ) {
        let container = try makeContainer(name: name)
        let context = container.mainContext
        let current = try makeUser(
            email: "current@example.com", username: "current", name: "Current",
            context: context
        )
        let other = try makeUser(
            email: "other@example.com", username: "other", name: "Other",
            context: context
        )
        for id in [1, 2, 3] {
            let bike = try makeBike(id: id, context: context)
            bike.owner = current
        }
        for id in [10, 11, 12] {
            let bike = try makeBike(id: id, context: context)
            bike.owner = other
        }
        context.processPendingChanges()
        try context.save()
        return (container, current, other)
    }

    /// Count bikes whose owner's email matches `email`.
    private func countBikesOwnedByEmail(_ email: String, context: ModelContext) throws -> Int {
        try context.fetchCount(
            FetchDescriptor<Bike>(
                predicate: #Predicate<Bike> { $0.owner?.email == email }
            ))
    }

    /// Replicates the exact stale-bike cleanup logic used by
    /// `MainContentPage.ViewModel.fetchProfile`. Kept in sync with the
    /// production code: any locally-stored `Bike` whose owner is the current
    /// user but whose identifier is not in `myBikeIdentifiers` has its owner
    /// set to nil. Bikes owned by other users are left untouched.
    private func cleanStaleBikes(
        myBikeIdentifiers: [Int],
        currentOwner: User,
        context: ModelContext
    ) throws {
        let currentUserId = currentOwner.persistentModelID
        let predicate = #Predicate<Bike> {
            $0.owner?.persistentModelID == currentUserId
                && !myBikeIdentifiers.contains($0.identifier)
        }
        let descriptor = FetchDescriptor<Bike>(predicate: predicate)
        let staleBikes = try context.fetch(descriptor)
        for bike in staleBikes {
            bike.owner = nil
        }
        context.processPendingChanges()
        try context.save()
    }

    // MARK: - Stale-bike cleanup behavior

    /// When the profile lists bikes 1 and 2, bike 3 (also owned by the current
    /// user) is unlinked. Bikes owned by other users are left untouched.
    @Test func test_staleBikesOfCurrentUserAreUnlinked_othersAreLeftAlone() throws {
        let (container, currentOwner, otherOwner) =
            try makePrepopulatedContainer(name: "stale_cleanup")
        let context = container.mainContext

        #expect(try countBikesOwnedByEmail(currentOwner.email, context: context) == 3)
        #expect(try countBikesOwnedByEmail(otherOwner.email, context: context) == 3)

        try cleanStaleBikes(
            myBikeIdentifiers: [1, 2],
            currentOwner: currentOwner,
            context: context
        )

        let currentAfter = try countBikesOwnedByEmail(currentOwner.email, context: context)
        #expect(
            currentAfter == 2,
            "Only the stale bike (id 3) should be unlinked from currentOwner")
        let otherAfter = try countBikesOwnedByEmail(otherOwner.email, context: context)
        #expect(
            otherAfter == 3,
            "Bikes owned by otherOwner must remain untouched")

        // Bike id 3 specifically should have no owner.
        let bike3 = try context.fetch(
            FetchDescriptor<Bike>(predicate: #Predicate<Bike> { $0.identifier == 3 })
        ).first
        #expect(bike3 != nil)
        #expect(bike3?.owner == nil, "Bike 3 should have its owner set to nil")
    }

    /// When the profile has no bikes, all of the current user's locally-stored
    /// bikes are unlinked. Other users' bikes are left alone.
    @Test func test_allBikesUnlinkedWhenProfileHasNoBikes() throws {
        let (container, currentOwner, otherOwner) =
            try makePrepopulatedContainer(name: "stale_all")
        let context = container.mainContext

        try cleanStaleBikes(
            myBikeIdentifiers: [],
            currentOwner: currentOwner,
            context: context
        )

        #expect(
            try countBikesOwnedByEmail(currentOwner.email, context: context) == 0,
            "All of currentOwner's bikes should be unlinked when the profile has no bikes")
        #expect(
            try countBikesOwnedByEmail(otherOwner.email, context: context) == 3,
            "Bikes owned by otherOwner must remain untouched")
    }

    /// When the profile contains all of the current user's bikes, no bikes are
    /// unlinked.
    @Test func test_noStaleBikesWhenProfileContainsAllBikes() throws {
        let (container, currentOwner, otherOwner) =
            try makePrepopulatedContainer(name: "stale_none")
        let context = container.mainContext

        try cleanStaleBikes(
            myBikeIdentifiers: [1, 2, 3],
            currentOwner: currentOwner,
            context: context
        )

        #expect(
            try countBikesOwnedByEmail(currentOwner.email, context: context) == 3,
            "No bikes should be unlinked when the profile contains all of the user's bikes")
        #expect(
            try countBikesOwnedByEmail(otherOwner.email, context: context) == 3,
            "Bikes owned by otherOwner must remain untouched")
    }

    /// Bikes whose owner is nil are never matched by the stale-bike predicate
    /// and remain untouched.
    @Test func test_bikesWithNilOwnerAreUnaffected() throws {
        let container = try makeContainer(name: "stale_nil_owner")
        let context = container.mainContext
        let currentOwner = try makeUser(
            email: "current@example.com", username: "current", name: "Current",
            context: context
        )
        // One owned bike that will become stale, one unowned bike.
        let ownedStale = try makeBike(id: 1, context: context)
        ownedStale.owner = currentOwner
        _ = try makeBike(id: 2, context: context)  // no owner
        context.processPendingChanges()
        try context.save()

        try cleanStaleBikes(
            myBikeIdentifiers: [],
            currentOwner: currentOwner,
            context: context
        )

        #expect(ownedStale.owner == nil, "The owned stale bike should be unlinked")
        let unowned = try context.fetch(
            FetchDescriptor<Bike>(predicate: #Predicate<Bike> { $0.identifier == 2 })
        ).first
        #expect(unowned != nil)
        #expect(unowned?.owner == nil, "An unowned bike should remain unowned")
    }

    // MARK: - fetchProfile guard behavior

    /// `fetchProfile` should short-circuit cleanly when the client is not
    /// authenticated, without touching the model context.
    @Test func test_fetchProfileReturnsEarlyWhenUnauthenticated() async throws {
        let (container, currentOwner, otherOwner) =
            try makePrepopulatedContainer(name: "unauthenticated")
        let context = container.mainContext
        let viewModel = MainContentPage.ViewModel()
        let client = try Client()
        #expect(client.authenticated == false)

        do {
            try await viewModel.fetchProfile(client: client, modelContext: context)
        } catch {
            Issue.record("Unauthenticated fetchProfile should return cleanly, not throw: \(error)")
        }

        #expect(try countBikesOwnedByEmail(currentOwner.email, context: context) == 3)
        #expect(try countBikesOwnedByEmail(otherOwner.email, context: context) == 3)
    }
}
