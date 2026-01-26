#!/usr/bin/swift sh
import Foundation
import XcodeProj  // @tuist ~> 9.7.2
import PathKit

/*
Run with 

g checkout BikeIndex.xcodeproj/ && swift-sh strip-SnapshotPreviews.swift BikeIndex.xcodeproj

or


g checkout BikeIndex.xcodeproj/ && swift-sh strip-SnapshotPreviews.swift BikeIndex.xcodeproj && xcodebuild -resolvePackageDependencies && fastlane gym
*/

guard CommandLine.arguments.count == 2 else {
    let arg0 = Path(CommandLine.arguments[0]).lastComponent
    fputs("usage: \(arg0) <project>\n", stderr)
    exit(1)
}

let projectPath = Path(CommandLine.arguments[1])
let xcodeproj = try XcodeProj(path: projectPath)

func printProperties(_ object: Any) {
    var properties = [String: Any]()
    Mirror(reflecting: object).children.forEach { (child) in
        if let property = child.label {
            properties[property] = child.value
        }
    }

    fputs("\(object)\n", stdout)
    fputs("\(type(of: object))\n", stdout)
    fputs("\(properties)\n", stdout)
}

// MARK: - REMOVE PACKAGE
fputs("----------- Build configs \n", stdout)
for projects in xcodeproj.pbxproj.projects {
    fputs("\tProject remote packages \(projects.remotePackages.count) \n", stdout)
    /*
    projects.remotePackages.map {
        fputs("\tDep repositoryURL = \($0.repositoryURL)\n", stdout)
        let matches = $0.repositoryURL == "https://github.com/EmergeTools/SnapshotPreviews"
        fputs("\tDep repositoryURL==snapshot? -> \(matches)\n", stdout)
    }
    */
    projects.remotePackages = projects.remotePackages.filter { $0.repositoryURL != "https://github.com/EmergeTools/SnapshotPreviews" }
    fputs("\tUPDATED projects with \(projects.remotePackages.count) \n", stdout)
}

// MARK: - REMOVE FRAMEWORKS
let developmentOnlyDependencies = [
    "PreviewGallery", "SnapshotPreferences", // Bike Index
    "SnapshottingTests", // Unit Tests
]
fputs("----------- Build configs \n", stdout)
for project in xcodeproj.pbxproj.projects {
    // DONE: Remove SnapshotPreviews package from Bike Index target (solvable)
    // DONE: Remove SnapshotPreviews package from unit tests target -- BLOCKED because packageProductDependencies does not contain SnapshottingTests, I think XcodeProj is not detecting the Unit Test "Frameworks and Libraries" contents correctly.
    // TODO: Remove Target.buildPhases that include developmentOnlyDependencies
    for target in project.targets { // PBXTarget
        fputs("\tTARGET A) package deps \(target.name), \(target.packageProductDependencies?.map { $0.productName }) \n", stdout)
        // target.packageProductDependencies?.forEach { printProperties($0) }
        // fputs("\tTARGET B) build config \(target.name), \(target.buildConfigurationList.map(\.buildConfigurations))\n", stdout)
        // fputs("\tTARGET C) deps \(target.name), \(target.dependencies.map(\.target?.name)), \(target.dependencies.map(\.product?.productName))\n", stdout)
        printProperties(target)
        fputs("\n", stdout)

        // 
        if var packageProductDependencies = target.packageProductDependencies {
            let starting = target.packageProductDependencies?.map { $0.productName }.joined(separator: ", ")
            fputs("start \(starting)\n", stdout)
            target.packageProductDependencies = packageProductDependencies.filter { 
                !developmentOnlyDependencies.contains($0.productName) 
            }
            let ending = target.packageProductDependencies?.map { $0.productName }.joined(separator: ", ")
            fputs("end \(ending)\n", stdout)
        }

        let allPhases = target.buildPhases
        for bPhase in allPhases where bPhase.buildPhase == .frameworks {
            fputs("\tbPhase.files \(bPhase.files) \n", stdout)
            fputs("\tbPhase.buildPhase \(bPhase.buildPhase) \n", stdout)
            fputs("\tbPhase.name \(bPhase.name()) \n", stdout)
            guard var files = bPhase.files, files.isEmpty == false else {
                continue
            }
            // for file in files {
            //     file.file.map { fputs("\t\tbPhase.files.file \($0) \n", stdout) }
            //     fputs("\t\tbPhase.files.product \(file.product), \(file.product?.productName) \n", stdout)
            //     fputs("\t\tbPhase.files.settings \(file.settings) \n", stdout)
            //     if let productName = file.product?.productName, developmentOnlyDependencies.contains(productName) {
            //         files.remove(file)
            //     }
            // }
            files.removeAll { file in
                if let productName = file.product?.productName, developmentOnlyDependencies.contains(productName) {
                    true
                } else {
                    false
                }
            }
            bPhase.files = files
        }
    }
}



try xcodeproj.write(path: projectPath)

