//
//  BikeIndexAppPreviewTest.swift
//  BikeIndexTests
//
//  Created by Jack on 12/27/24.
//

import XCTest
import SnapshottingTests

class BikeIndexAppPreviewTest: SnapshotTest {

    // Return the type names of previews like "MyApp.MyView._Previews" to selectively render only some previews
    override class func snapshotPreviews() -> [String]? {
        return nil
    }

    // Use this to exclude some previews from generating
    override class func excludedSnapshotPreviews() -> [String]? {
        return nil
    }
}
