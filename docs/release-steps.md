# Release Steps

> [!TIP]
> As of [PR #128](https://github.com/bikeindex/bike_index_ios/pull/128) steps 6. (create archive build) and 7. (upload to App Store Connect) are automated for branches matching the release format in step 1.

> [!NOTE]
> Screenshot capture (steps 4–5) is now automated via `fastlane snapshot` against the sandbox — see [release-screenshot-capture.md](release-screenshot-capture.md).

1. Create a release branch named in the format `release/v1.5`
2. Open the project and run the test suite
3. Increment the BikeIndex Target Version and Build numbers in Default.xcconfig
4. ~~Capture screenshots for "iPhone 17 Plus"~~ _automated in [PR #163](https://github.com/bikeindex/bike_index_ios/pull/163)!_
5. ~~Capture screenshots for iPad~~ _automated in [PR #163](https://github.com/bikeindex/bike_index_ios/pull/163)!_
6. ~~Create an Archive build~~ _automated in [PR #128](https://github.com/bikeindex/bike_index_ios/pull/128)!_
7. ~~Upload the build to App Store connect and submit it to TestFlight~~ _automated in PR #128!_
8. Confirm the screenshots match the current UI (a helpful tell is the date on the iPad screenshots!) and/or check the continuous delivery 'Capture Snapshots' step output
9. Update the "What's New" text
10. Submit the build to App Store Review
	- After the build is approved, create the release PR for the branch and merge it into `main`
	- If new builds are needed for any reason, increment the build number and commit the change within the release PR
11. After the build is approved and merged,
	1. create a new git tag for the release on main with the short form of the release `v1.5`
	2. create a new GitHub release https://github.com/bikeindex/bike_index_ios/releases/new with the `v1.5 tag on main with two \# sections: "What's New" and "Description", copy and paste these paragraphs from App Store Connect
12. Write release notes based on the changes from the previous tag (such as `v1.4.1`) and the earlier TestFlight build release notes.
