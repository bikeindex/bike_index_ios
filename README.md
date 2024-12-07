# Bike Index

![GitHub License](https://img.shields.io/github/license/bikeindex/bike_index_ios) | [![iOS Test Suite](https://github.com/bikeindex/bike_index_ios/actions/workflows/ios.yml/badge.svg)](https://github.com/bikeindex/bike_index_ios/actions/workflows/ios.yml)

> [!IMPORTANT]
> This project is incomplete and under active development.
> No guarantees are provided.

iOS client for [bikeindex.org](https://bikeindex.org)

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

- Requirements: Xcode 16.0
- Target deployment: iOS 17.2

This project uses SwiftUI and SwiftData. At this time iOS (iPhone) is the primary development target with a long-term goal to include iPad and Mac support.

###### Run an individual test case

Fastlane scan can run a single test case such as: `bundle exec fastlane scan --only-testing "BikeIndexUITests/ManufacturerKeyboardUITestCase"`.

###### Set up suite of tools

1. Install brew
2. `brew install bundle`
    - Note: Brew bundle is separate from the Gem bundle
3. `brew bundle install`
4. `rbenv install`
5. `bundle install`

At this point the full suite of tools should be installed and available.

#### Tests

Set up the local suite of tools and run `bundle exec fastlane ios tests`.

## License

[Apache License 2.0](LICENSE.txt)
