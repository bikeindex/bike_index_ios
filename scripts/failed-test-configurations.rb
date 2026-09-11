#!/usr/bin/env ruby
# Parse a JUnit report (from `fastlane scan`) and print, one per line, the
# `--only-test-configurations` selector for each test still failing after the
# testplan's retryOnFailure repetitions (i.e. its final "repetition" run has a
# <failure>/<error>). Output: "<target>/<class>/<method>" per line.
# Usage: ./scripts/failed-test-configurations.rb path/to/report.junit

require "rexml/document"

def main
  path = ARGV[0]
  abort "usage: #{File.basename($0)} <report.junit>" if path.nil?
  abort "report not found: #{path}" unless File.exist?(path)

  doc = REXML::Document.new(File.read(path))
  target = infer_target(path)

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

# Test target name = last "_"-separated segment of the report dir
# (e.g. "test_output_iPhone 17_UITests" -> "UITests").
def infer_target(path)
  base = File.basename(File.dirname(path))
  base.sub(/\Atest_output[_ -]?/, "").split("_").last
end

main
