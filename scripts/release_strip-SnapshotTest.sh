#!/usr/bin/exec sh

# gem install xcodeproj
# ../adjust-project.rb

brew install swift-sh
xcodebuild -resolvePackageDependencies


# TODO: push / pop changes if any state management fails
