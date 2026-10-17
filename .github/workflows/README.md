# Metadata

Image details: https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md

### Required CI checks

Required CI checks can be found in GitHub > Settings > Rulesets > [Default ruleset] > Require status checks to pass > Show additional settings

### Updating actions created by GitHub

The allowed reusable workflows listed at https://github.com/bikeindex/bike_index_ios/settings/actions are version-gated. Be sure to update this list when incrementing the version of an action.

## Flaky-test retry in `integration.yml`

This workflow automatically retries **only the tests that are still failing**
after a full test pass, so a single flaky test does not fail the whole run.
It works in two layers: in-run retries (via the test plan) and a follow-up
CI job that re-runs just the stragglers.

### How a failure is detected and retried

1. **In-run retries.** `SharedTests/AllTests.xctestplan` sets
   `testRepetitionMode: retryOnFailure` with `maximumTestRepetitions: 4`, so
   each test is re-run up to 4 times *within* a single `fastlane scan` call.
   A test that passes on any repetition is green; one that fails all 4 is
   "still failing." (The report also sets `testExecutionOrdering: random`,
   `repeatInNewRunnerProcess: true`, and `testTimeoutsEnabled: true`.)
2. **Still-failing collection.** After `test-unit` / `test-ui` run, the
   `Collect still-failing tests` step (runs on `failure()`) parses the JUnit at
   `fastlane/test_output/report.junit` (written by trainer from the xcresult, not
   the xcpretty formatter — see `fastlane/Scanfile`) with
   `scripts/failed-test-configurations.rb` and emits a newline-separated list
   of `<target>/<class>/<method>` selectors into the job's `failed-tests`
   output.
3. **Targeted re-run.** `retry-unit` / `retry-ui` run only when
   `needs.test-<x>.result == 'failure'` *and* `failed-tests` is non-empty. They
   re-run `fastlane scan` with
   `--xcargs="-only-testing:@<file>"` where the file holds exactly those
   selectors. The retry job is bounded to 30 minutes so a hanging test cannot
   run the job to the 2h+ runner watchdog.
4. **Post-retry still-failing.** The retry job's `Collect still-failing tests
   (post-retry)` step (runs on `always()`) re-parses the retry's JUnit and
   emits a `still-failing` output, so the "still failing after retry" signal is
   captured even if the retry step is killed mid-run by its timeout.

Selector granularity is framework-aware (see `failed-test-configurations.rb`):
- **XCTest** → function-level `<target>/<class>/<method>`.
- **Swift Testing** → whole-suite `<target>/<suite>`. A function-level
  identifier for a Swift Testing test silently runs **zero** tests, which would
  make the retry "pass" vacuously and mask the failure.

### The vacuous-run guard (why a "green" retry is trusted)

The single worst failure mode for a targeted retry is a **malformed selector**:
xcodebuild matches no test, runs nothing, and the step "passes" — silently
masking the real failure. The `--guard` mode of
`scripts/failed-test-configurations.rb` defends against this:

- The retry step writes its expected selectors to
  `$GITHUB_WORKSPACE/.retry-<unit|ui>-expected.txt` (a path that persists across
  steps; `mktemp` would not).
- The post-retry collect step runs
  `ruby scripts/failed-test-configurations.rb --guard <report> <target> <expected>`,
  which reconciles each expected selector against the tests that actually
  executed in the post-retry JUnit. It prints an `[ok]` / `[MISSING]` line per
  selector and **exits 1 (failing the job)** if *zero* expected tests ran —
  turning a silent no-op pass into a loud, actionable failure. A Swift Testing
  suite selector legitimately expands to many executed tests, so the check is
  "at least one executed per selector," not exact equality.

### Validating the selectors (the two questions)

**(1) Are the emitted failed selectors correct?** Two independent checks:
- **Self-test** — `build-tests` runs
  `ruby scripts/failed-test-configurations.rb --self-test` on every build. It
  asserts the framework mapping (Swift Testing → whole-suite, XCTest →
  function-level), that a retried-then-passed test is ignored (last `<testcase>`
  wins), that a skipped sibling does not zero out a suite's executed count,
  and that `--guard` passes for executed selectors and fails for a vacuous
  one. If the parser's core logic regresses, the build fails before any test
  runs.
- **Real-data spot check** — run the parser against a captured JUnit and verify
  the selectors by hand against the raw XML:
  ```sh
  ruby scripts/failed-test-configurations.rb fastlane/test_output/report.junit UnitTests
  ruby scripts/failed-test-configurations.rb --executed fastlane/test_output/report.junit UnitTests
  # or, with debug: FTC_DEBUG=1 ruby scripts/failed-test-configurations.rb ...
  ```
  Confirm the emitted selectors exactly match the tests that have `<failure>`
  on their *last* repetition in the report.

**(2) Does the retry job actually consume them (run only those tests)?** The
post-retry guard is the answer. In the `Retry failed …` job log, look for:
- `retrying UnitTests:` — the *expected* selectors (what was asked to run).
- The `guard:` reconciliation block — `[ok]` lines for each selector that
  actually executed, `[MISSING]` for any that matched nothing.
- If a selector is malformed, the job fails with
  `retry-unit guard failed: expected selectors matched no executed test
  (vacuous retry)` instead of silently passing.

The end-to-end proof is a **green retry job** where the guard reports
`[ok]` for every expected selector and `still-failing` comes back empty. Until
such a run exists, the guard + self-test are what give confidence that the
consumption path is correct.

**Local reproduction (no CI):** you can prove the consumption path against the
cached build products:
```sh
fastlane scan --xcargs="-only-testing:UnitTests/<Class>/<method>" \
  --device="iPhone 17" --test_without_building=true
```
then confirm the post-run JUnit contains exactly that test. (Mirror the
workflow's newline-delimited `-only-testing:@<file>` form when a method name
contains spaces.)

### Re-running the retry on GitHub (and its limits)

GitHub's re-run feature is **job-level, not test-level.** The three options
(see https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs)
are:
- **Re-run all jobs** — `gh run rerun RUN_ID`
- **Re-run failed jobs** — `gh run rerun RUN_ID --failed`
- **Re-run a specific job** — `gh run rerun --job JOB_ID`

"Re-run failed jobs" re-executes *whole job definitions* that failed — it has
no notion of picking individual tests. But because the targeted-retry logic
(read the still-failing selectors, build the `-only-testing` list, run the
guarded re-run) lives *inside* the `retry-unit` / `retry-ui` job, **"Re-run
failed jobs" is exactly the manual "retry only the failed tests" path:** it
re-runs just `retry-unit` / `retry-ui`, which re-read the original run's
cached `needs.test-<x>.outputs['failed-tests']` and re-run *only* those
selectors. You do **not** re-run the full 96-test pass.

Limits (GitHub Actions): a run can be re-run within **30 days** of its start,
for a maximum of **50 re-runs** (the count includes full re-runs and subset
re-runs together). Re-runs use the *original* actor's privileges and the
original `GITHUB_SHA` / `GITHUB_REF`.

When you do **not** want the targeted re-attempt but a fresh full pass, use
`workflow_dispatch` ("Manually run a workflow") — it re-dispatches the whole
workflow (rebuild + full pass), and the targeted retry fires again if the same
tests still fail. A `workflow_dispatch` starts a *new* run, so it cannot read
the previous run's `needs.*.outputs`; any cross-run retry of specific tests
would have to download the previous run's JUnit artifact and re-derive the
selectors. For the common "the flaky test is still flaky, give it another
shot" case, the UI's "Re-run failed jobs" is the intended tool.
