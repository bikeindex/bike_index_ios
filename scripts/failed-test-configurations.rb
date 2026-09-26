#!/usr/bin/env ruby
# Parse a JUnit report (from `fastlane scan`) and print, one per line, the
# `--only-test-configurations` selector for each test still failing after the
# testplan's retryOnFailure repetitions (i.e. its final "repetition" run has a
# <failure>/<error>). Output: "<target>/<class>/<method>" per line.
# Usage: ./scripts/failed-test-configurations.rb path/to/report.junit

require "rexml/document"
require "fileutils"
require "tmpdir"

def main
  path = ARGV[0]
  abort "usage: #{File.basename($0)} <report.junit>" if path.nil?
  abort "report not found: #{path}" unless File.exist?(path)

  doc = REXML::Document.new(File.read(path))
  target = infer_target(path)
  warn "inferred test target: #{target.inspect}"

  # key => [max repetition index (0-based), failed? at that index]
  best = {}

  # REXML path queries don't recurse nested <testsuite>s reliably; walk directly.
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        cls = child.attributes["classname"]
        m = child.attributes["name"]
        if cls && m
          failed = child.get_elements("failure").any? || child.get_elements("error").any?
          rep = repetition_index(child)
          key = cls + "\u0000" + m
          if rep
            b = best[key]
            best[key] = [rep, failed] if b.nil? || rep >= b[0]
          else
            best[key] ||= [0, failed] # no repetition props: last occurrence wins
          end
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)

  best.each do |key, (_, failed)|
    next unless failed
    cls, m = key.split("\u0000", 2)
    puts "#{target}/#{cls}/#{m.sub(/\(\)$/, '')}"
  end
rescue REXML::ParseException => e
  warn "failed to parse #{path}: #{e.message}"
  exit 1
end

# 0-based index from the `repetition` property ("First Run" -> 0, "Retry N" -> N), else nil.
def repetition_index(tc)
  (tc.get_elements("properties") || []).each do |p|
    p.each_element("property") do |prop|
      next unless prop.attributes["name"] == "repetition"
      v = prop.attributes["value"]
      return 0 if v == "First Run"
      m = v.match(/\ARetry (\d+)\z/)
      return m[1].to_i if m
    end
  end
  nil
end

# The Xcode test *target* name, used as the first segment of an
# `--only-test-configurations` selector ("UITests/BikeIndexUITests/test_foo").
#
# scan writes the JUnit file to `fastlane/test_output/<output_directory>_<scheme>/report.junit`
# where the directory basename equals the *target* name passed to
# `--only-testing` (e.g. "UITests", "UnitTests") — NOT the Xcode scheme and NOT
# the class name (the class, "BikeIndexUITests", is already in the classname).
# Prefer that; fall back to the outermost <testsuite> name.
def infer_target(path)
  base = File.basename(File.dirname(path))
  return base if base.match?(/\A\p{Word}+\z/)

  # Fallback: outermost <testsuite> under the root <testsuites> element.
  root = REXML::Document.new(File.read(path)).root
  suite = root.elements.to_a("testsuite").first
  suite && suite.attributes["name"]
end

if ARGV[0] == "--self-test"
  # Regression guard: the selector's first segment must be the *target* name
  # (the value passed to --only-testing), and the class/method must match the
  # JUnit classname/name. A wrong prefix is exactly what silently no-ops the
  # CI retry job, so this must keep passing.
  fixture_path = File.join(Dir.mktmpdir("ftc-selftest"), "report.junit")
  File.write(fixture_path, <<~XML)
    <?xml version='1.0' encoding='UTF-8'?>
    <testsuites tests='2' failures='1'>
      <testsuite name='UITests' tests='2' failures='1'>
        <testsuite name='BikeIndexUITests' tests='2' failures='1'>
          <testcase name='test_flaky()' classname='BikeIndexUITests'>
            <failure message='boom'/>
            <properties><property name='repetition' value='Retry 2'/></properties>
          </testcase>
          <testcase name='test_ok()' classname='BikeIndexUITests'>
            <properties><property name='repetition' value='First Run'/></properties>
          </testcase>
        </testsuite>
      </testsuite>
    </testsuites>
  XML
  # Re-parse the fixture through the same code path the CLI uses.
  doc = REXML::Document.new(File.read(fixture_path))
  target = infer_target(fixture_path)
  best = {}
  walk = lambda do |el|
    el.each_element do |child|
      if child.name == "testcase"
        cls = child.attributes["classname"]
        m = child.attributes["name"]
        if cls && m
          failed = child.get_elements("failure").any? || child.get_elements("error").any?
          rep = repetition_index(child)
          key = cls + "\u0000" + m
          if rep
            b = best[key]
            best[key] = [rep, failed] if b.nil? || rep >= b[0]
          else
            best[key] ||= [0, failed]
          end
        end
      end
      walk.call(child)
    end
  end
  walk.call(doc.root)
  selectors = best.filter_map { |k, (_, f)| f ? k : nil }
                 .map { |k| c, m = k.split("\u0000", 2); "#{target}/#{c}/#{m.sub(/\(\)$/, '')}" }
  expected = ["UITests/BikeIndexUITests/test_flaky"]
  FileUtils.remove_entry(File.dirname(fixture_path))
  abort "self-test FAILED: got #{selectors.inspect}, expected #{expected.inspect}" unless selectors == expected
  puts "self-test OK"
  exit 0
end

main
