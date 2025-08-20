# Release Steps

1. Create a release branch in the format `release/v1.5`
2. Open the project and run the test suite
3. Increment the BikeIndex Target Version and Build numbers in the project settings
4. Capture screenshots for iPhone
	1. Build and run the project for iPhone
	2. Set the simulator date/time with `xcrun simctl status_bar booted override --time "2007-01-09T14:41:00.000Z" --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100`
	3. Capture each screenshot as needed
5. Capture screenshots for iPad
	1. Build and run the project for iPad
	2. Set the simulator date/time with `xcrun simctl status_bar booted override --time "2007-01-09T14:41:00.000Z" --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100`
	3. Capture each screenshot as needed
	4. When opening "Register a bike" page, clear the "Owner Email" field
6. Create an Archive build
7. Upload the build to App Store connect and submit it to TestFlight
8. Update the screenshots
9. Update the "What's New" text
10. Submit the build to App Store Review
	- After the build is approved, create the PR for the branch and merge it into `main`
	- If new builds are needed for any reason, increment the build number and commit the change
11. After the build is approved and merged, 
	1. create a new git tag for the release on main with the short form of the release `v1.5`
	2. create a new GitHub release https://github.com/bikeindex/bike_index_ios/releases/new with the `v1.5` tag on main with two \# sections: "What's New" and "Description", copy and paste these paragraphs from App Store Connect
