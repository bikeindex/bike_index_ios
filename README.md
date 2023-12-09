# Bike Index

⚠️ This project is incomplete and under active development. ⚠️
⚠️ No guarantees are provided. ⚠️

iOS client for bikeindex.org

## Quick Start

To get started:

1. Copy the BikeIndex-template file into BikeIndex-development and BikeIndex-production
	- BikeIndex-development is used for the `Debug (development)` build scheme. This should use your local development instance.
	- BikeIndex-production is used for the `Debug (production)` build scheme and for archive/release builds.
2. Follow the template instructions to provide your own application configuration
	- Sign in to https://bikeindex.org/oauth/applications and create an application
	- or sign in to your local instance and create an API key
	- Add a Callback URL to the application
	- Paste the callback URL, application ID, and secret into the corresponding .xcconfig file
3. If building for a device you will need to provide a bundle identifier and your development team
4. Build and run!

### Development

- Requirements: Xcode 15.0.1
- Target deployment: iOS 17

This project uses SwiftUI and SwiftData. At this time iOS (iPhone) is the primary development target with a long-term goal to include iPad and Mac support.

## License

[Apache License 2.0](LICENSE.txt)
