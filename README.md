# [![BIKE INDEX][bike-index-logo]][bike-index] ![GitHub License](https://img.shields.io/github/license/bikeindex/bike_index_ios) [![iOS Test Suite](https://github.com/bikeindex/bike_index_ios/actions/workflows/ios.yml/badge.svg)](https://github.com/bikeindex/bike_index_ios/actions/workflows/ios.yml) ![iTunes App Store](https://img.shields.io/itunes/v/6477746994?label=Latest%20App%20Store%20release)

[bike-index-logo]: https://github.com/bikeindex/bike_index/blob/main/public/icon-dark.svg?raw=true
[bike-index]: https://www.bikeindex.org

iOS client for [bikeindex.org](https://bikeindex.org)

### TestFlight

The public beta for pre-release builds is available at https://testflight.apple.com/join/TVaDioGl. Pre-release builds may not always be available.

## Quick Start

To get started:

1. Copy the BikeIndex-template.xcconfig file into BikeIndex-development.xcconfig and BikeIndex-production.xcconfig files.
	- BikeIndex-development is used for the `Debug (development)` build scheme. This should use your local development instance.
	- BikeIndex-production is used for the `Debug (production)` build scheme and for archive/release builds. This is only required for releases.
2. Follow the template instructions to provide your own application configuration
	- Sign in to https://bikeindex.org/oauth/applications and create an application
	- or sign in to your local instance and create an API key
	- Add a Callback URL to the application
	- Paste the callback URL, application ID, and secret into the corresponding .xcconfig file
3. If building for a device you will need to provide a bundle identifier and your development team
4. Build and run!

### Development

- Requirements: Xcode 16.2
- Target deployment: iOS 17.2

This project uses SwiftUI and SwiftData. At this time iOS (iPhone) is the primary development target with a goal to include iPad and Mac support.

###### Set up suite of tools

1. Install brew
2. `brew install bundle`
    - Note: Brew bundle is separate from the Gem bundle
3. `brew bundle install`
4. `rbenv install`
5. `bundle install`

At this point the full suite of tools should be installed and available.

###### Git hooks

Git hooks are in the local [.githooks](.githooks) directory and can be connected with `git config --local core.hooksPath .githooks/`. These files should be marked executable already.

###### Swift Format

Formatting is done with [swiftlang/swift-format](https://github.com/swiftlang/swift-format/)

Lint with: `swift format lint --recursive  BikeIndex/ UnitTests/ UITests/`

Format with: `swift format --in-place --recursive  BikeIndex/ UnitTests/ UITests/`

The configuration will be loaded by default from [.swift-format](.swift-format)

#### Tests

Test-driven development is an important tool for this project. In your local environment run the tests with Xcode, or set up the local suite of tools to install fastlane and run `bundle exec fastlane ios tests`.

##### UI Test configuration

Running UI Tests from Xcode may cache logged-in state. Set up a credentials xcconfig file to ensure UI tests are always able to log-in and proceed (for both Xcode and fastlane invocations).

1. Copy the `Test-credentials-template.xcconfig` file to `Test-credentials.xcconfig`.
2. Edit the source to add a test username and password that are valid credentials for the server configured by corresponding build scheme (see: BikeIndex-development.xcconfig) you'll be using.
	- This test account must have already authorized the Bike Index OAuth app used in your corresponding build scheme's .xcconfig.
3. In the simulator erase all content and settings to clear out any previous credentials.
4. Run the UI tests through Xcode or `bundle exec fastlane scan --only-testing "UITests"`!

##### Run an individual test case

Fastlane scan can run a single test case such as: `bundle exec fastlane scan --only-testing "UITests/ManufacturerKeyboardUITestCase"`.

## Sponsorship

Bike Index is a 501(c)(3) nonprofit: https://bikeindex.org/why-donate

## License

[AGPL-3.0 License](LICENSE.txt)
