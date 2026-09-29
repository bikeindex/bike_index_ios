#!/usr/bin/env ruby
# Parse a JUnit report (from `fastlane scan`) and print, one per line, the
# `--only-testing` selector for each test still failing after the testplan's
# retryOnFailure repetitions. Output: "<target>/<class>/<method>" per line.
#
# Usage:
#   scripts/failed-test-configurations.rb path/to/report.junit <target>
#
# `<target>` is the Xcode *test target* name (the value passed to
# `--only-testing`), e.g. "UnitTests". It MUST be passed explicitly. The JUnit
# does not reliably encode it:
#   * the report always lives in a generic `test_output/` directory, not a
#     per-target directory, so the directory name is useless;
#   * under the xcpretty formatter the outermost <testsuite name> is the
#     *class* name; under the trainer (xcresult) formatter it is the target.
# So the target cannot be inferred from the file path or the XML alone.
#
# Retries: with `retryOnFailure` a retried test is written as MULTIPLE
# <testcase> elements (one per attempt, in log order). Neither xcpretty's nor
# trainer's JUnit carries a "repetition" property, so the LAST <testcase> for a
# given (class, method) is the authoritative (final) result. We therefore use
# last-occurrence-wins: a test that failed then passed on a retry is NOT
# reported; only a test whose final attempt failed is.

require "rexml/document"
require "fileutils"
require "tmpdir"

# Returns an array of "<target>/<class>/<method>" selectors, one per test whose
# FINAL (last) <testcase> in the report has a <failure> or <error>.
def failing_selectors(path, target)
  doc = REXML::Document.new(File.read(path))

  # key "<class>\u0000<method>" => failed? (last occurrence wins)
  best = {}
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        cls = child.attributes["classname"]
        m = child.attributes["name"]
        if cls && m
          failed = child.get_elements("failure").any? || child.get_elements("error").any?
          best[cls + "\u0000" + m] = failed
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)

  best.filter_map do |key, failed|
    next unless failed
    cls, m = key.split("\u0000", 2)
    "#{target}/#{cls}/#{m.sub(/\(\)$/, '')}"
  end
end

def main
  path, target = ARGV[0], ARGV[1]
  abort "usage: #{File.basename($0)} <report.junit> <target>" if path.nil? || target.nil?
  abort "report not found: #{path}" unless File.exist?(path)

  failing_selectors(path, target).each { |s| puts s }
rescue REXML::ParseException => e
  warn "failed to parse #{path}: #{e.message}"
  exit 1
end

if ARGV[0] == "--self-test"
  # Regression guard. A wrong first segment (target) or a first-occurrence-wins
  # bug is exactly what silently no-ops / mis-fires the CI retry job, so this
  # must keep passing. It exercises the SAME code path the CLI uses.
  dir = Dir.mktmpdir("ftc-selftest")
  fixture_path = File.join(dir, "report.junit")
  File.write(fixture_path, <<~XML)
    <?xml version='1.0' encoding='UTF-8'?>
    <testsuites tests='5' failures='3'>
      <testsuite name='BikeIndexAppPreviewTest' tests='5' failures='3'>
        <!-- flaky: failed attempt 1, passed attempt 2 -> final PASS -> NOT listed -->
        <testcase classname='BikeIndexAppPreviewTest' name='test_flaky()' time='1.0'>
          <failure message='boom'/>
        </testcase>
        <testcase classname='BikeIndexAppPreviewTest' name='test_flaky()' time='0.5'/>
        <!-- still failing: failed both attempts -> final FAIL -> listed -->
        <testcase classname='BikeIndexAppPreviewTest' name='test_broken()' time='1.0'>
          <failure message='boom'/>
        </testcase>
        <testcase classname='BikeIndexAppPreviewTest' name='test_broken()' time='1.0'>
          <failure message='boom'/>
        </testcase>
        <!-- snapshot method name with spaces must round-trip intact -->
        <testcase classname='BikeIndexAppPreviewTest' name='portrait-Main Content Page-0-15()' time='1.0'>
          <failure message='snapshot diff'/>
        </testcase>
      </testsuite>
    </testsuites>
  XML
  got = failing_selectors(fixture_path, "UnitTests").sort
  expected = [
    "UnitTests/BikeIndexAppPreviewTest/test_broken",
    "UnitTests/BikeIndexAppPreviewTest/portrait-Main Content Page-0-15"
  ].sort
  FileUtils.remove_entry(dir)
  abort "self-test FAILED: got #{got.inspect}, expected #{expected.inspect}" unless got == expected
  puts "self-test OK"
  exit 0
end

main
