//
//  ManufacturerTests.swift
//  UnitTests
//
//  Created by Jack on 11/16/24.
//

import OSLog
import SwiftData
import Testing
import XCTest

@testable import BikeIndex

@MainActor
struct ManufacturerTests {

    /// Ensure that a duplicate with the same ``AutocompleteManufacturer/identifier`` is 'upserted' instead of added.
    @Test func test_manufacturer_deduplication() async throws {
        func createSampleManufacturer(text: String = "Jamis") -> AutocompleteManufacturer {
            AutocompleteManufacturer(
                text: text,
                category: "frame_mnfg",
                slug: "jamis",
                priority: 100,
                searchId: "m_201",
                identifier: 201
            )
        }

        let config = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: true)
        let container = try ModelContainer(
            for: AutocompleteManufacturer.self,
            configurations: config
        )
        let descriptor = FetchDescriptor<AutocompleteManufacturer>()

        // https://developer.apple.com/documentation/swiftdata/maintaining-a-local-copy-of-server-data
        #expect(
            container.mainContext.autosaveEnabled,
            "Autosave must be enabled for deduplication")
        let manufacturer_preCreate = try container.mainContext.fetch(descriptor)
        #expect(manufacturer_preCreate.count == 0)

        let jamisManufacturer = createSampleManufacturer()
        do {
            container.mainContext.insert(jamisManufacturer)
            try container.mainContext.save()
        }

        let manufacturer_postInsert = try container.mainContext.fetch(descriptor)
        #expect(manufacturer_postInsert.count == 1)
        #expect(manufacturer_postInsert.first?.text == "Jamis")

        // MARK: Perform actual test
        let duplicateEntry = createSampleManufacturer(text: "Jamis 2")
        do {
            container.mainContext.insert(duplicateEntry)
            try container.mainContext.save()
        }
        let fetch_postDuplicateInsert = try container.mainContext.fetch(descriptor)
        #expect(
            fetch_postDuplicateInsert.count == 1,
            "Duplicate found, \(fetch_postDuplicateInsert.map(\.id)), \(fetch_postDuplicateInsert.map(\.identifier))"
        )
        #expect(
            manufacturer_postInsert.first?.text == "Jamis 2",
            "Only one entry should be present and should have the latest `text` value.")
    }

}
