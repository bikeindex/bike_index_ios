# UI Test Troubleshooting

This page records recurring UI-test failures that are **not** caused by the iOS app
code but by the **sandbox data / server state**, plus the small iOS-side test
robustness fixes that were applied to the webview-content assertions.

The sandbox is seeded from `db/seeds.rb` in the `bike_index` (Rails) repository.
When a UI test fails, first check whether the failure is in this category before
assuming an app regression.

## How to read a UI-test failure

The GHA `UITests` job uploads a `test_output_iPhone 17_UITests` artifact that
contains a `BikeIndex.xcresult` bundle. Even when a test fails on an assertion
timeout, the bundle includes **screen recordings** and **UI snapshots** for each
repetition. Extract the last frame of a failing test's recording to see exactly
what was on screen:

```sh
# Download the artifact, then:
xcrun xcresulttool export attachments \
  --path BikeIndex.xcresult --output-path /tmp/att \
  # --only-failures   # uncomment to limit to failing tests

# Map attachments to tests:
python3 - <<'PY'
import json
for e in json.load(open('/tmp/att/manifest.json')):
    for a in e['attachments']:
        if 'Screen Recording' in a.get('suggestedHumanReadableName',''):
            print(e['testIdentifier'], a['exportedFileName'])
PY

# Grab the last frame of a recording:
ffmpeg -ss "$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 <recording.mp4> | xargs -I{} echo {} - 1 | bc)" \
  -i <recording.mp4> -frames:v 1 out.jpg
```

## Failures that are sandbox / server problems

These were observed failing identically on `main` and on feature branches, so they
are environmental rather than app regressions.

### 1. Auth-gated webview pages show "Sorry, you have to log in."

**Affected tests:** `test_settings_account_pages`,
`test_acknowledgements_webView_navigation_history` (and any test that navigates
the webview to an auth-gated page such as `/settings` or `/oauth/applications`).

**Symptom:** the webview renders the BikeIndex login form with a
"Sorry, you have to log in." banner instead of the expected page.

**Cause:** the app has **two independent sessions**:
- the **native/API session** — the OAuth token stored in the keychain
  (`Client.auth`), which is what `startWithSignIn()` establishes; and
- the **webview session** — the `auth` cookie in the `WKWebView`'s
  `WKWebsiteDataStore`.

Auth-gated webview pages depend on the **cookie**, not the keychain token. If the
webview login (email/password entry in `Robot+Authentication.signIn()`) does not
complete and set the `auth` cookie before the test navigates to an auth-gated
page, the server redirects to the login form. This can happen when the server is
slow or the OAuth callback is cancelled before the cookie is written.

**Fix (sandbox/CI):** ensure the test account (`user@bikeindex.org`, see
`db/seeds/seed_test_users.rb`) has a valid, long-lived web session and that the
OAuth app authorization for that account has not lapsed. Confirm the account is
still listed on
<https://sandbox.review.bikeindex.org/oauth/authorized_applications>.

**Not fixable by:** increasing timeouts or loosening element queries — the correct
content is never served while the session is absent.

### 2. A page returns 404

**Affected test:** `test_register_bike_stolen_guide_link`.

**Symptom:** the webview renders the BikeIndex 404 page ("We're sorry, the page
you were looking for wasn't there.").

**Cause:** the "How to get your stolen bike back" guide URL that
`RegisterStolenBikeRobot` taps no longer resolves on the sandbox. Either the page
was removed/moved, or (per failure #1) the missing webview session causes a
redirect that lands on 404.

**Fix (sandbox):** verify the guide URL exists on the sandbox and, if it moved,
update the button label/URL the test expects (see
`UITests/MainContentRobots/RegisterStolenBikeRobot.swift`).

### 3. A seeded bike is in an unexpected status

**Affected test:** `test_basic_bike_detail_navigation`.

**Symptom:** `tapFirstBike()` lands on a bike whose detail page shows an alert
such as "That bike was impounded." instead of the expected "View Bike" link, so
the `isHittable == true` assertion fails.

**Cause:** the seed data includes an **impounded** bike owned by the primary test
user. In `db/seeds/seed_bikes.rb`, the block seeded by `b3d509a15`
("Seed a found bike and an unregistered parking notification", #3900) creates a
`Specialized Sirrus` with `status: "status_impounded"` and the description
"Found unlocked near the Golden Gate Park tennis courts". Depending on list
ordering, `tapFirstBike()` can navigate to this bike.

**Fix (sandbox/iOS):** either ensure the first bike in the list is a normal
registered bike, or make the test target a specific known-stable bike rather than
"the first one".

## iOS-side test robustness fixes (applied)

These are legitimate test bugs in this repo, fixed independently of the sandbox
issues above.

### Scanned-sticker message uses substring matching

**Tests:** `test_authenticated_bikes_scanned_id_universal_link`,
`test_guest_bikes_scanned_id_universal_link`.

The site renders the confirmation as a single paragraph with the sticker code in
a `<code>` run:

```
You scanned the sticker BR 000 1, which is assigned to this bike.
```

The previous assertion queried three **exact-label** static texts
(`"You scanned"`, `"BR 000 1"`, `", which is assigned to this bike."`). When the
webview exposes the sentence as a single static text (label = the whole
sentence), those exact matches fail even though the content is fully rendered.

`UniversalLinksRobot.checkUnlinkedMessage()` now matches on distinctive
**substrings** (`label CONTAINS 'assigned to this bike'` and
`label CONTAINS 'BR 000 1'`), which is resilient to the site rewording the
surrounding prose.

### `Robot.Predicate.contains` / `.doesNotContain` now do substring matching

`Predicate.contains` previously formatted to `label == '…'` (exact equality)
despite its name. It is now `label CONTAINS '…'` (and `.doesNotContain` is
`label DOES NOT CONTAIN '…'`). These cases were unused before the scanned-sticker
change; the fix aligns the format with the intent.
