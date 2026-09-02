# Automated App Store Screenshots

App Store screenshots are captured with `fastlane snapshot` against the **hosted sandbox** (`https://sandbox.review.bikeindex.org`) as part of the continuous delivery process.

The sandbox's review-app banner is hidden by `WebScripts` (`#review-app-banner { display: none }`), so it never appears in captures. This banner is used for development.

## Capturing locally

> [!TIP]
> A great way to align local behavior and development against `delivery.yml` is to start a new worktree. This will resemble the blank slate of a CI/CD run.

1. Generate the environment configuration per the README instructions for:
    1. Test-credentials.xcconfig
    2. BikeIndex-development.xcconfig
    3. BikeIndex-production.xcconfig
2. Validate them with `scripts/validate-xcconfig.sh` (development and test).
3. Run `fastlane snapshot`
    - Defaults to the full four-device matrix
    - or provide a `devices:` parameter to change the device(s) list.
4. Validate the output with `scripts/validate-screenshots.rb` (expected number of screensohts and _some_ valid contents).
5. Check the `fastlane snapshot` output manually.
    - Fastlane will automatically open the `fastlane/Preview.html` file containing the snapshots in your browser.
    - Suppress the automatic opening with the `--skip_open_summary` flag.

## When and why CI runs it

`fastlane snapshot` runs in the shared part of `delivery.yml`, in both flow modes. CI generates the same xcconfig files first, then validates the 12 PNGs and uploads them as a 30-day artifact.

- **Weekly canary** — the `schedule` trigger (Monday 06:00 UTC) and a manual dispatch with `SNAPSHOT_VALIDATION_ONLY=true` run *only* the snapshot path (no archive, no App Store Connect / TestFlight upload). Its purpose is to prove the capture flow still works — sandbox up, seeded user and bike 44 intact, navigation and banner-hiding still correct — before a real release depends on it.
- **Release** — a `push` to `release/v*` runs the snapshot path first; only if it passes does the job continue to keychain/codesigning, archive, and `deliver` (which uploads the fresh screenshots to App Store Connect and the ipa to TestFlight). A failing capture therefore aborts the release before anything is built or uploaded.

The sandbox is a safe environment that is close-to-production, safe to modify / regenerates, and publicly available. Sandbox contents are generated from the database seeds.

