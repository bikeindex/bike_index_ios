#!/usr/bin/env ruby
# frozen_string_literal: true

# validate-screenshots.rb
#
# Validates that the fastlane snapshot output is a correct, non-blank set of
# PNG screenshots. Designed to run after `fastlane snapshot`.
#
# Usage:
#   ruby scripts/validate-screenshots.rb [SCREENSHOT_DIR] [EXPECTED_COUNT]
#
# Examples:
#   ruby scripts/validate-screenshots.rb
#   ruby scripts/validate-screenshots.rb fastlane/screenshots 3
#
# Checks:
#   1. The screenshot directory exists.
#   2. The number of PNG files exactly matches EXPECTED_COUNT
#      (one per ScreenshotUITest method).
#   3. Every file is > 5 KB (below that is likely a blank / error image).
#   4. Every file is a real PNG (magic-byte check).

SCREENSHOT_DIR = ARGV[0] || "fastlane/screenshots"
EXPECTED_COUNT = (ARGV[1] || 1).to_i
MIN_BYTES = 5 * 1024
PNG_MAGIC = "\x89PNG\r\n\x1a\n".b

fail "[validate-screenshots] Screenshot directory not found: #{SCREENSHOT_DIR}" unless Dir.exist?(SCREENSHOT_DIR)

png_files = Dir.glob(File.join(SCREENSHOT_DIR, "**", "*.png")).sort

if png_files.size != EXPECTED_COUNT
  msg = "[validate-screenshots] Expected exactly #{EXPECTED_COUNT} PNG(s), found #{png_files.size} in #{SCREENSHOT_DIR}:"
  png_files.each { |f| msg += "\n  - #{f}" }
  abort msg
end

errors = []

png_files.each do |path|
  size = File.size(path)
  if size < MIN_BYTES
    errors << "#{path} is too small (#{size} bytes < #{MIN_BYTES})"
    next
  end

  header = File.binread(path, 8)
  unless header == PNG_MAGIC
    errors << "#{path} is not a PNG (bad magic bytes: #{header.inspect})"
    next
  end

  puts "  ✓ #{File.basename(path)} (#{size} bytes)"
end

if errors.any?
  errors.each { |e| warn "[validate-screenshots] #{e}" }
  abort "[validate-screenshots] #{errors.size} of #{png_files.size} screenshot(s) failed validation"
end

puts "[validate-screenshots] OK: #{png_files.size} screenshot(s), all PNGs, all > #{MIN_BYTES} bytes"
