#!/usr/bin/env ruby
# Parse a JUnit report (from `fastlane scan`) and print, one per line, the
# `-only-testing` identifier for each test still failing after the testplan's
# retryOnFailure repetitions.
#
# Usage:
#   scripts/failed-test-configurations.rb path/to/report.junit <target> [source_root]
#
#   <target>       the Xcode test target name (value passed to --only-testing),
#                  e.g. "UnitTests". Passed explicitly because the JUnit does
#                  not reliably encode it (the report lives in a generic
#                  test_output/ dir, and the outermost <testsuite> name is a
#                  class name under the xcpretty formatter).
#   [source_root]  directory to scan for Swift Testing suites (default: CWD).
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

# Returns an array of "-only-testing" identifiers for the still-failing tests.
def failing_selectors(path, target, source_root = Dir.pwd)
  swift_suites = swift_testing_suites(source_root)

  # class => { method => failed? } (last occurrence wins per method)
  results = {}
  doc = REXML::Document.new(File.read(path))
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        cls = child.attributes["classname"]
        m = child.attributes["name"]
        if cls && m
          failed = child.get_elements("failure").any? || child.get_elements("error").any?
          (results[cls] ||= {})[m] = failed
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)

  selectors = []
  results.each do |cls, methods|
    failing = methods.select { |_, failed| failed }
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

def main
  path, target = ARGV[0], ARGV[1]
  source_root = ARGV[2] || Dir.pwd
  abort "usage: #{File.basename($0)} <report.junit> <target> [source_root]" if path.nil? || target.nil?
  abort "report not found: #{path}" unless File.exist?(path)

  warn "swift testing suites: #{swift_testing_suites(source_root).sort.inspect}" if ENV["FTC_DEBUG"]
  failing_selectors(path, target, source_root).each { |s| puts s }
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
  # Trainer/xcresult-style report: both frameworks share the same <testcase>
  # shape, so only the source scan can tell them apart.
  report = File.join(dir, "report.junit")
  File.write(report, <<~XML)
    <?xml version='1.0' encoding='UTF-8'?>
    <testsuites tests='6' failures='4'>
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
      </testsuite>
    </testsuites>
  XML
  got = failing_selectors(report, "UnitTests", src)
  expected = [
    "UnitTests/SwiftThingTests", # whole suite (test_a retried-pass ignored; test_b failed)
    "UnitTests/XThingTests/test_xc_one" # function-level
  ].sort
  FileUtils.remove_entry(dir)
  abort "self-test FAILED: got #{got.inspect}, expected #{expected.inspect}" unless got == expected
  puts "self-test OK"
  exit 0
end

main
