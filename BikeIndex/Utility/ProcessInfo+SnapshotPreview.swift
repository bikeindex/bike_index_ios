//
//  ProcessInfo+SnapshotPreview.swift
//  BikeIndex
//
//  Created by Jack on 3/16/25.
//

import SwiftUI

/// https://github.com/EmergeTools/SnapshotPreviews?tab=readme-ov-file#environment-variables
extension ProcessInfo {
    var isRunningPreviews: Bool {
        environment["EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] == "1"
            || environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
