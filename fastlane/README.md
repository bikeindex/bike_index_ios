fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios tests_iphone17

```sh
[bundle exec] fastlane ios tests_iphone17
```

Run test suite on iPhone 17

### ios tests_iphone17pro

```sh
[bundle exec] fastlane ios tests_iphone17pro
```

Run test suite on iPhone 17 Pro

### ios tests_ipad

```sh
[bundle exec] fastlane ios tests_ipad
```

Run test suite on iPad (A16)

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run test suite (all default simulators)

### ios BI_build_release_archive

```sh
[bundle exec] fastlane ios BI_build_release_archive
```

Perform all tasks to make a new release: increment build, archive, upload

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
