//
//  ContributorAttributionBackgroundChipTests.swift
//  UnitTests
//
//  Created by Jack on 10/19/25.
//

import Testing
import Foundation
@testable import BikeIndex

/// A touch of excessive assurances to prove that changing ContributorPlaces will always wrap around the FrameColors and to provide the right data to `AttributionPlacesView`.
/// Additionally any change to FrameColors count would need strict attention.
struct ContributorAttributionBackgroundChipTests {

    @Test func test_repeating_backgroundColors() async throws {
        let places = ContributorPlaces.allCases
        let frameColors = FrameColor.allCases
        let count = Int(round(Double(places.count) / Double(frameColors.count)))
        let backgroundColors = Array(
            repeating: frameColors, count: count)
            .flatMap { $0 }
        #expect(backgroundColors.count >= places.count)
        #expect(backgroundColors.count >= frameColors.count)
        #expect(places.count >= frameColors.count)
    }

    @Test func test_contributor_places_randomized_is_sufficient() async throws {
        #expect(ContributorPlaces.allCases.count == ContributorPlaces.randomized.count)
    }

    @Test func test_frame_colors_count_is_sufficient() async throws {
        #expect(FrameColor.allCases.count == 13)
    }

}
