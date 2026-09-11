#!/usr/bin/env ruby
#
# failed-test-configurations.rb
#
# Parses a JUnit XML report (produced by `fastlane scan`, e.g.
# fastlane/test_output/report.junit) and prints, one per line, the
# Xcode `--only-test-configurations` selector for every test that is
# STILL FAILING after the testplan's `retryOnFailure` repetitions.
#
# How it decides "still failing":
#   The testplan sets `testRepetitionMode = retryOnFailure` with a
#   maximum of 3 total runs. `scan`'s JUnit report emits one <testcase>
#   per run, each tagged with a `repetition` property:
#     "First Run", "Retry 1", "Retry 2", ...
#   A test is only reported as failed if its FINAL repetition
#   (the last `repetition` value seen for that classname+method)
#   contains a <failure> or <error>. Tests that recovered on an
#   earlier retry are excluded — that's the whole point of retrying.
#
#   If a report does not carry `repetition` properties (e.g. retries
#   were disabled), the fallback is: the test's LAST occurrence must
#   have a failure/error.
#
# Output format (one selector per line), the format expected by
# `xcodebuild -only-testing:` and `fastlane scan --only-test-configurations`:
#   <testTarget>/<testClass>/<testMethod>
# e.g.
#   UITests/BikeIndexUITests/test_guest_bikes_scanned_id_universal_link
#
# The <testTarget> is inferred from the report's file name. `scan`
# writes report.junit into a per-(target, device) directory whose name
# ends with the test target (e.g. "..._UITests/report.junit"). We use
# the last path segment with the common prefixes stripped.
#
# Usage:
#   ./scripts/failed-test-configurations.rb path/to/report.junit
#
# Exit codes:
#   0 - report parsed (0 or more failures)
#   1 - report file missing / unparseable / usage error

require "rexml/document"

def main
  path = ARGV[0]
  abort "usage: #{File.basename($0)} <report.junit>" if path.nil?
  abort "report not found: #{path}" unless File.exist?(path)

  doc = REXML::Document.new(File.read(path))

  # Determine the test target name from the report path.
  # e.g. "test_output_iPhone 17_UITests/report.junit" -> "UITests"
  target = infer_target(path)

  # For each test (keyed by "classname##{method}"), record the highest
  # repetition index seen, and whether that final repetition failed.
  final_repetition = {} # key => max repetition index (0-based)
  repetition_failed = {} # key => failed? at that max repetition
  has_repetition_props = false

  # REXML's each_element/get_elements with a path string does not reliably
  # recurse through the nested <testsuite> wrappers, so we walk the tree
  # directly. Repetitions are emitted in chronological order (First Run,
  # Retry 1, Retry 2, ...), so a later <testcase> for the same
  # classname+method is a later run.
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        class_name = child.attributes["classname"]
        method = child.attributes["name"]
        unless class_name.nil? || method.nil?
          failed = child.get_elements("failure").any? ||
                   child.get_elements("error").any?
          rep_index = repetition_index(child) # 0-based, nil if absent
          key = class_name + "\u0000" + method
          if rep_index
            has_repetition_props = true
            if final_repetition[key].nil? || rep_index >= final_repetition[key]
              final_repetition[key] = rep_index
              repetition_failed[key] = failed
            end
          else
            # No repetition property: last occurrence wins.
            final_repetition[key] ||= 0
            repetition_failed[key] = failed
          end
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)

  repetition_failed.each do |key, failed|
    next unless failed
    class_name, method = key.split("\u0000", 2)
    method = method.sub(/\(\)$/, "") # "test_foo()" -> "test_foo"
    puts "#{target}/#{class_name}/#{method}"
  end

  $stderr.puts "# parsed report=#{path} target=#{target} " \
               "# repetition_props=#{has_repetition_props} " \
               "# reported_failures=#{repetition_failed.count { |_, f| f }}"
rescue REXML::ParseException => e
  $stderr.puts "failed to parse #{path}: #{e.message}"
  exit 1
end

# Returns the 0-based repetition index from the `repetition` property,
# or nil if the testcase has no `repetition` property.
def repetition_index(tc)
  # get_elements returns an Array in REXML 3.x.
  props = (tc.get_elements("properties") || [])
  props.each do |p|
    p.each_element("property") do |prop|
      next unless prop.attributes["name"] == "repetition"
      val = prop.attributes["value"]
      return 0 if val == "First Run"
      m = val.match(/\ARetry (\d+)\z/)
      return m[1].to_i if m
    end
  end
  nil
end

# Infer the Xcode test target name from the report path. `scan` writes
# report.junit into a directory named like "<something>_<Target>".
def infer_target(path)
  base = File.basename(File.dirname(path)) # e.g. "test_output_iPhone 17_UITests"
  # Strip a leading "test_output" prefix and any device token, keep the
  # trailing CamelCase target.
  name = base.sub(/\Atest_output[_ -]?/, "")
  # Drop the device portion (everything up to the last underscore that
  # precedes a CamelCase word).
  parts = name.split("_")
  target = parts.last # "UITests" / "UnitTests"
  target
end

main
