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
fputs("----------- Build configs \n", stdout)
for project in xcodeproj.pbxproj.projects {
    for target in project.targets { // PBXTarget
        fputs("\tTARGET A) package deps \(target.name), \(target.packageProductDependencies?.map { $0.productName }) \n", stdout)
        // target.packageProductDependencies?.forEach { printProperties($0) }
        fputs("\tTARGET B) build config \(target.name), \(target.buildConfigurationList.map(\.buildConfigurations))\n", stdout)
        fputs("\tTARGET C) deps \(target.name), \(target.dependencies.map(\.target?.name)), \(target.dependencies.map(\.product?.productName))\n", stdout)
        // TODO: Remove SnapshotPreviews package from Bike Index target (solvable)
        // TODO: Remove SnapshotPreviews package from unit tests target -- BLOCKED because packageProductDependencies does not contain SnapshottingTests, I think XcodeProj is not detecting the Unit Test "Frameworks and Libraries" contents correctly.
        printProperties(target)
        fputs("\n", stdout)
    }
}



try xcodeproj.write(path: projectPath)

