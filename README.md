# Bike Index

⚠️ This project is incomplete and under active development. ⚠️
⚠️ No guarantees are provided. ⚠️

iOS client for bikeindex.org

To get started:

1. Copy the BikeIndex-template file into BikeIndex-development and BikeIndex-production
2. Follow the template instructions to provide your own OAuth token from https://bikeindex.org/oauth/applications or a local instance
3. If building for a device you will need to provide a bundle identifier and your development team
4. Build and run!

### Development

Requirements: Xcode 15.0.1

This project targets iOS 17+ to use SwiftUI and SwiftData. At this time iOS (iPhone) is the primary development target with a long-term goal to include iPad and Mac support.

#### TODO List

- [ ] Add AuthenticatedUser.Memberships and Organization
- [ ] Add *unit tests for* AuthenticatedUser.Memberships and Organization
- [ ] Fix SwiftData exceptions
- [ ] Switch navigation to path based stack to fix post-register behavior
- [ ] Fix navigation for settings view on iphone (use path based stack)
- [ ] Add SafariView and open edit bikes page in Safari view
- [ ] Build and run UserTests on this branch/commit/tag in order to capture a bug report for the swift compiler team
	- `branch compiler-bug-snapshot, tag: compiler-snapshot-bug-in-usertests)`

## License

[Apache License 2.0](LICENSE.txt)
