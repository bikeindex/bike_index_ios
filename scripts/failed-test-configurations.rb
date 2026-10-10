#!/usr/bin/env ruby
# Parse a JUnit report (from `fastlane scan`) and print, one per line, the
# `-only-testing` identifier for each test still failing after the testplan's
# retryOnFailure repetitions.
#
# Usage:
#   scripts/failed-test-configurations.rb [--self-test] path/to/report.junit <target> [source_root]
#   scripts/failed-test-configurations.rb --executed path/to/report.junit <target> [source_root]
#   scripts/failed-test-configurations.rb --guard path/to/report.junit <target> <expected_file> [source_root]
#
#   <target>       the Xcode test target name (value passed to --only-testing),
#                  e.g. "UnitTests". Passed explicitly because the JUnit does
#                  not reliably encode it (the report lives in a generic
#                  test_output/ dir, and the outermost <testsuite> name is a
#                  class name under the xcpretty formatter).
#   [source_root]  directory to scan for Swift Testing suites (default: CWD).
#
# Modes:
#   (default)   print one -only-testing identifier per line for each test that
#               is still failing after the testplan's retryOnFailure repetitions.
#   --executed  print one -only-testing identifier per line for each test that
#               actually EXECUTED (passed or failed), deduped.
#   --guard     vacuous-run guard for the post-retry collect step. Reads the
#               expected selectors (newline-delimited -only-testing identifiers
#               from <expected_file>), parses the post-retry report, and verifies
#               that at least one expected test actually EXECUTED. Prints the
#               expected-vs-executed reconciliation to stdout and exits 1 (failing
#               the CI step) if ZERO expected tests ran -- the tell-tale of a
#               malformed selector that made scan run nothing and "pass"
#               vacuously, masking the real failure. A Swift Testing suite
#               selector legitimately expands to several executed tests, so the
#               check is ">= 1 executed" per selector, not exact equality.
#
# Output granularity (the whole point of this script):
#   - XCTest:        <target>/<class>/<method>   function-level works.
#   - Swift Testing: <target>/<suite>            class-level ONLY. A
#                                                 function-level identifier for
#                                                 a Swift Testing test silently
#                                                 runs ZERO tests, which would
#                                                 make the retry "succeed"
#                                                 vacuously and mask the failure.
#
# A type is a Swift Testing suite if it declares at least one @Test function.
# That is detected by scanning the checked-out sources (the CI job runs in the
# repo root). The JUnit itself cannot tell the two frameworks apart: under the
# trainer/xcresult JUnit both are just <testcase classname=... name=...>, and
# under the xcpretty formatter Swift Testing tests are omitted entirely (which
# is why CI forces a non-xcpretty formatter so the report includes them).
#
# Retries: with retryOnFailure a retried test is written as multiple
# <testcase> elements (one per attempt, in order) with no "repetition"
# property, so the LAST <testcase> for a (class, method) is the final result.

require "rexml/document"
require "fileutils"
require "tmpdir"
require "set"

# A testcase counts as "executed" (for the vacuous-run guard) unless it is an
# explicit <skipped/> with time='0' -- the only marker the xcresult/trainer
# JUnit emits for a test that never ran (e.g. a Swift Testing @Test marked
# @Enabled(false)). A bare <testcase/> (passed, no time), a <failure>/<error>
# child (failed), or a non-zero time (ran) all count as executed. The check is
# deliberately permissive: the guard only cares that at least one test matched
# the -only-testing selector, so false positives (counting a skipped test as
# executed) are harmless; false negatives (a bad selector running zero tests)
# are what we must catch.
def executed?(tc)
  skipped = tc.get_elements("skipped").any?
  return false if skipped && tc.attributes["time"].to_f.zero?
  true
end

# Returns { class_name => { method => { failed:, executed: } } } (last
# occurrence per method wins) from a JUnit report.
def parse_results(path)
  results = {}
  doc = REXML::Document.new(File.read(path))
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        cls = child.attributes["classname"]
        m = child.attributes["name"]
        if cls && m
          failed = child.get_elements("failure").any? || child.get_elements("error").any?
          exec = executed?(child)
          prev = results[cls] && results[cls][m]
          # Last occurrence wins, but a test that executed in an earlier attempt
          # and was skipped in a later one still counts as executed (retryOnFailure
          # writes one element per attempt; the final one is authoritative for
          # pass/fail but not for "did it ever run").
          (results[cls] ||= {})[m] = { failed: failed, executed: prev ? (prev[:executed] || exec) : exec }
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)
  results
end

# Returns an array of "-only-testing" identifiers for the still-failing tests.
def failing_selectors(path, target, source_root = Dir.pwd)
  swift_suites = swift_testing_suites(source_root)
  results = parse_results(path)

  selectors = []
  results.each do |cls, methods|
    failing = methods.select { |_, info| info[:failed] }
    next if failing.empty?
    # The JUnit classname may be module-prefixed ("UnitTests.ManufacturerTests")
    # depending on the formatter; -only-testing wants the bare type name.
    bare = cls.to_s.split(".").last
    if swift_suites.include?(bare)
      selectors << "#{target}/#{bare}" # Swift Testing: whole suite (dedupes methods)
    else
      failing.each_key { |m| selectors << "#{target}/#{bare}/#{m.sub(/\(\)$/, '')}" } # XCTest
    end
  end
  selectors.sort
end

# Returns an array of "-only-testing" identifiers for every test that actually
# executed (passed or failed), deduped, one per line. Swift Testing suites are
# emitted as the whole-suite identifier; XCTest as function-level.
def executed_selectors(path, target, source_root = Dir.pwd)
  swift_suites = swift_testing_suites(source_root)
  results = parse_results(path)

  selectors = []
  results.each do |cls, methods|
    executed = methods.select { |_, info| info[:executed] }
    next if executed.empty?
    bare = cls.to_s.split(".").last
    if swift_suites.include?(bare)
      selectors << "#{target}/#{bare}" # Swift Testing: whole suite (dedupes methods)
    else
      executed.each_key { |m| selectors << "#{target}/#{bare}/#{m.sub(/\(\)$/, '')}" } # XCTest
    end
  end
  selectors.sort
end

# Scans source_root and returns the set of type names that are Swift Testing
# suites (they declare at least one @Test function). A lightweight
# brace-matching scan; good enough for well-formed Swift.
def swift_testing_suites(source_root)
  suites = Set.new
  files = Dir[File.join(source_root, "**", "*.swift")].reject do |f|
    f =~ %r{(^|/)(build|\.build|DerivedData|Pods|Carthage)(/|\z)}
  end
  files.each do |f|
    stack = [] # [type_name, brace_depth]
    File.foreach(f) do |line|
      code = line.sub(/\/\/.*\z/, "") # drop trailing line comment
      if code =~ /\b(struct|class|extension)\s+([A-Z]\w*)/
        stack.push([ $2, 0 ])
      end
      suites << stack.last[0] if code =~ /@Test\b/ && stack.any?
      code.each_char do |c|
        if c == "{"
          stack.last[1] += 1 if stack.any?
        elsif c == "}" && stack.any?
          stack.last[1] -= 1
          stack.pop if stack.last[1] <= 0
        end
      end
    end
  end
  suites.to_a
end

# The vacuous-run guard. Compares the expected -only-testing selectors against
# the tests that actually executed in the post-retry report and reports a
# loud, actionable verdict. Returns 0 if at least one expected test ran, 1
# otherwise.
def guard_selectors(path, target, expected_file, source_root = Dir.pwd)
  expected = File.read(expected_file).split("\n").map(&:strip).reject(&:empty?)
  if expected.empty?
    puts "guard: no expected selectors to check (nothing was asked to retry)"
    return 0
  end

  executed = executed_selectors(path, target, source_root)
  executed_set = executed.to_set

  # Reconcile each expected selector. A Swift Testing suite selector (Target/Suite)
  # matches any executed selector under that suite; an XCTest function selector
  # (Target/Class/Method) must appear exactly.
  matched = []
  unmatched = []
  expected.each do |sel|
    parts = sel.split("/")
    is_suite = parts.length == 2 # Target/Suite (Swift Testing)
    hit =
      if is_suite
        executed_set.any? { |e| e.split("/").first(2) == parts }
      else
        executed_set.include?(sel) # exact function-level match
      end
    (hit ? matched : unmatched) << sel
  end

  puts "guard: #{expected.size} expected selector(s), #{matched.size} executed, #{unmatched.size} not executed"
  matched.each { |s| puts "  [ok]      #{s}" }
  unmatched.each { |s| puts "  [MISSING] #{s} (selector matched no test -- vacuous)" }

  if matched.empty?
    warn "guard FAILED: no expected test executed. scan likely ran zero tests and passed vacuously."
    warn "  This usually means a malformed -only-testing selector (wrong target, class, or method name)."
    warn "  The retry 'success' is NOT a real pass -- the originally-failing test never ran."
    return 1
  end
  0
end

def main
  mode = :default
  if ARGV[0] == "--executed"
    mode = :executed
    ARGV.shift
  elsif ARGV[0] == "--guard"
    mode = :guard
    ARGV.shift
  end
  path, target = ARGV[0], ARGV[1]
  expected_file = ARGV[2]
  source_root = ARGV[3] || Dir.pwd
  usage = "usage: #{File.basename($0)} [--executed|--guard] <report.junit> <target> [--guard <expected_file>] [source_root]"
  abort usage if path.nil? || target.nil?
  abort "--guard requires <expected_file>" if mode == :guard && expected_file.nil?
  abort "report not found: #{path}" unless File.exist?(path)
  abort "expected file not found: #{expected_file}" if mode == :guard && !File.exist?(expected_file)

  warn "swift testing suites: #{swift_testing_suites(source_root).sort.inspect}" if ENV["FTC_DEBUG"]
  case mode
  when :executed
    executed_selectors(path, target, source_root).each { |s| puts s }
  when :guard
    exit(guard_selectors(path, target, expected_file, source_root))
  else
    failing_selectors(path, target, source_root).each { |s| puts s }
  end
rescue REXML::ParseException => e
  warn "failed to parse #{path}: #{e.message}"
  exit 1
end

if ARGV[0] == "--self-test"
  # Regression guard: Swift Testing failures must map to a whole-suite
  # identifier (function-level would silently run zero tests), while XCTest
  # failures stay function-level. A wrong mapping is exactly what no-ops the
  # CI retry, so this must keep passing. Runs the real code paths.
  dir = Dir.mktmpdir("ftc-selftest")
  src = File.join(dir, "src")
  FileUtils.mkdir_p(src)
  # A Swift Testing suite (implicit @Suite struct with @Test funcs)
  File.write(File.join(src, "SwiftThingTests.swift"), <<~SWIFT)
    import Testing
    struct SwiftThingTests {
        @Test func test_a() { #expect(true) }
        @Test func test_b() { #expect(true) }
    }
  SWIFT
  # A classic XCTest class (NOT a Swift Testing suite)
  File.write(File.join(src, "XThingTests.swift"), <<~SWIFT)
    import XCTest
    final class XThingTests: XCTestCase {
        func test_xc_one() { }
        func test_xc_two() { }
    }
  SWIFT
  # A Swift Testing suite where one @Test is @Enabled(false): the trainer JUnit
  # writes it as a <skipped/> element (time='0'). The vacuous-run guard must
  # still count the OTHER, executed @Test in the same suite, so a skipped
  # sibling must not zero out the suite's executed count.
  File.write(File.join(src, "SwiftSkipTests.swift"), <<~SWIFT)
    import Testing
    struct SwiftSkipTests {
        @Test func test_enabled() { #expect(true) }
        @Enabled(false)
        @Test func test_disabled() { #expect(true) }
    }
  SWIFT
  # Trainer/xcresult-style report: both frameworks share the same <testcase>
  # shape, so only the source scan can tell them apart.
  report = File.join(dir, "report.junit")
  File.write(report, <<~XML)
    <?xml version='1.0' encoding='UTF-8'?>
    <testsuites tests='8' failures='4'>
      <testsuite name='UnitTests'>
        <testsuite name='SwiftThingTests'>
          <testcase classname='SwiftThingTests' name='test_a()'><failure message='x'/></testcase>
          <testcase classname='SwiftThingTests' name='test_a()'/><!-- retried, passed -->
          <testcase classname='SwiftThingTests' name='test_b()'><failure message='x'/></testcase>
          <testcase classname='SwiftThingTests' name='test_b()'><failure message='x'/></testcase>
        </testsuite>
        <testsuite name='XThingTests'>
          <testcase classname='XThingTests' name='test_xc_one()'><failure message='x'/></testcase>
          <testcase classname='XThingTests' name='test_xc_two()'/><!-- passed -->
        </testsuite>
        <testsuite name='SwiftSkipTests'>
          <testcase classname='SwiftSkipTests' name='test_enabled()' time='1.0'/>
          <testcase classname='SwiftSkipTests' name='test_disabled()' time='0.0'><skipped message='disabled'/></testcase>
        </testsuite>
      </testsuite>
    </testsuites>
  XML
  got = failing_selectors(report, "UnitTests", src)
  expected = [
    "UnitTests/SwiftThingTests", # whole suite (test_a retried-pass ignored; test_b failed)
    "UnitTests/XThingTests/test_xc_one" # function-level
  ].sort
  abort "failing self-test FAILED: got #{got.inspect}, expected #{expected.inspect}" unless got == expected

  # --executed mode: the vacuous-run guard. Every test that actually ran must
  # appear; a skipped sibling must NOT zero out its suite; a retried-then-passed
  # test counts as executed (it ran).
  got_exec = executed_selectors(report, "UnitTests", src)
  expected_exec = [
    "UnitTests/SwiftThingTests", # test_a ran (failed then passed), test_b ran
    "UnitTests/SwiftSkipTests",  # test_enabled ran; test_disabled skipped -> suite still executed
    "UnitTests/XThingTests/test_xc_one",
    "UnitTests/XThingTests/test_xc_two"
  ].sort
  abort "executed self-test FAILED: got #{got_exec.inspect}, expected #{expected_exec.inspect}" unless got_exec == expected_exec

  # --guard mode: the vacuous-run reconciliation. (a) a selector that ran must
  # pass; (b) a selector that matched nothing must fail the step (exit 1) --
  # this is the exact failure mode that would otherwise silently mask a retry.
  good_expected = File.join(dir, "good.txt")
  File.write(good_expected, "UnitTests/SwiftThingTests\nUnitTests/XThingTests/test_xc_one\n") # both executed
  rc_good = guard_selectors(report, "UnitTests", good_expected, src)
  abort "guard self-test FAILED: expected rc 0 for executed selectors, got #{rc_good}" unless rc_good == 0

  bad_expected = File.join(dir, "bad.txt")
  File.write(bad_expected, "UnitTests/XThingTests/test_does_not_exist\n") # matched nothing
  rc_bad = guard_selectors(report, "UnitTests", bad_expected, src)
  abort "guard self-test FAILED: expected rc 1 for vacuous selector, got #{rc_bad}" unless rc_bad == 1

  FileUtils.remove_entry(dir)
  puts "self-test OK"
  exit 0
end

main
