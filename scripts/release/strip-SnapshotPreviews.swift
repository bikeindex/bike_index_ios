#!/usr/bin/swift sh
import Foundation
import XcodeProj  // @tuist ~> 9.7.2
import PathKit

/**
 * ## Purpose
 * The SnapshotPreviews package is useful for development but can be safely stripped from
 * release builds to reduce app size and prevent any runtime risk.
 *
 * ## Test with:
   g checkout BikeIndex.xcodeproj/ \
       && ./scripts/release/strip-SnapshotPreviews.swift BikeIndex.xcodeproj \
       && xcodebuild -resolvePackageDependencies \
       && fastlane gym
*/

guard CommandLine.arguments.count == 2 else {
    let arg0 = Path(CommandLine.arguments[0]).lastComponent
    fputs("usage: \(arg0) <project>\n", stderr)
    exit(1)
}

let projectPath = Path(CommandLine.arguments[1])
let xcodeproj = try XcodeProj(path: projectPath)
let developmentOnlyDependencies = [
    "PreviewGallery", "SnapshotPreferences", // Bike Index
    "SnapshottingTests", // Unit Tests
]

// MARK: - 1. REMOVE PACKAGE
fputs("1. Scanning remote packages\n", stdout)
for projects in xcodeproj.pbxproj.projects {
    fputs("\tFound \(projects.remotePackages.count) remote packages \n", stdout)
    projects.remotePackages = projects.remotePackages.filter { $0.repositoryURL != "https://github.com/EmergeTools/SnapshotPreviews" }
    fputs("\tStripping and leaving \(projects.remotePackages.count) remote packages \n", stdout)
}

// MARK: - 2. REMOVE FRAMEWORKS

fputs("2. Remove frameworks \n", stdout)
for project in xcodeproj.pbxproj.projects {
    for target in project.targets { // PBXTarget
        // 2.A Remove dependency
        fputs("\t2.A) Scanning package product dependencies for \(target.name) \n", stdout)
        if var packageProductDependencies = target.packageProductDependencies {
            let starting = (target.packageProductDependencies ?? []).map { $0.productName }.joined(separator: ", ")
            fputs("\tFound dependencies: \(starting)\n", stdout)
            target.packageProductDependencies = packageProductDependencies.filter { 
                !developmentOnlyDependencies.contains($0.productName) 
            }
            let ending = (target.packageProductDependencies ?? []).map { $0.productName }.joined(separator: ", ")
            fputs("\tStripping and leaving dependencies: \(ending)\n", stdout)
        }

        // 2.B Remove build phase
        fputs("\t2.B) Scanning build phases for \(target.name) \n", stdout)
        let allPhases = target.buildPhases
        for bPhase in allPhases where bPhase.buildPhase == .frameworks {
            guard var files = bPhase.files, files.isEmpty == false else {
                continue
            }
            let starting = files.compactMap { $0.product }.map { $0.productName }.joined(separator: ", ")
            fputs("\tFound framework build phases for: \(starting)\n", stdout)
            files.removeAll { file in
                if let productName = file.product?.productName, developmentOnlyDependencies.contains(productName) {
                    true
                } else {
                    false
                }
            }
            let ending = files.compactMap { $0.product }.map { $0.productName }.joined(separator: ", ")
            fputs("\tStripping and leaving build phases for: \(ending)\n", stdout)
            bPhase.files = files
        }
        fputs("\t2) Done scanning \(target.name)\n\n", stdout)
    }
}



try xcodeproj.write(path: projectPath)

