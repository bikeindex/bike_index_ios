#!/usr/bin/env ruby
# frozen_string_literal: true

# validate-sandbox.rb
#
# Validates that the sandbox server has the required OAuth application
# registered and that test stickers are present. Designed to run as a
# pre-flight check before integration / UI tests in CI.
#
# Usage:
#   ruby scripts/validate-sandbox.rb
#
# Environment variables (all optional, defaults shown):
#   SANDBOX_URL        (default: https://sandbox.review.bikeindex.org)
#   SANDBOX_EMAIL      (default: user@bikeindex.org)
#   SANDBOX_PASSWORD   (default: pleaseplease12)
#   API_CLIENT_ID      (from Config.xcconfig)
#
# Checks:
#   1. Can authenticate a session via the two-step login form.
#   2. The OAuth client is registered (authorize with valid client_id
#      returns a code or consent page, not 401).
#   3. The test sticker BR0001 is present (scanned redirect targets a
#      bike page, not the user root).
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed (message on stderr)

require "net/http"
require "uri"
require "json"

SANDBOX_URL  = URI(ENV.fetch("SANDBOX_URL", "https://sandbox.review.bikeindex.org"))
EMAIL        = ENV.fetch("SANDBOX_EMAIL", "user@bikeindex.org")
PASSWORD     = ENV.fetch("SANDBOX_PASSWORD", "pleaseplease12")
CLIENT_ID    = ENV.fetch("API_CLIENT_ID", "")
STICKER_ID   = "BR0001"
SCOPE        = "read_bikes"
USER_AGENT   = "BikeIndexIOS-Validate/1.0"

fail "[validate-sandbox] API_CLIENT_ID environment variable is required" if CLIENT_ID.empty?

# ---------------------------------------------------------------------------
# Minimal cookie jar + HTTP session
# ---------------------------------------------------------------------------
class SandboxSession
  attr_reader :cookies

  def initialize(base_url)
    @base = base_url
    @http = Net::HTTP.new(base_url.host, base_url.port)
    @http.use_ssl = (base_url.scheme == "https")
    @cookies = {}
  end

  def get(path)
    req = Net::HTTP::Get.new(path)
    req["User-Agent"] = USER_AGENT
    apply_cookies(req)
    res = @http.request(req)
    store_cookies(res)
    res
  end

  def post(path, form)
    req = Net::HTTP::Post.new(path)
    req["User-Agent"] = USER_AGENT
    apply_cookies(req)
    req.set_form_data(form)
    res = @http.request(req)
    store_cookies(res)
    res
  end

  private

  def apply_cookies(req)
    req["Cookie"] = @cookies.map { |k, v| "#{k}=#{v}" }.join("; ") unless @cookies.empty?
  end

  def store_cookies(res)
    (res.get_fields("set-cookie") || []).each do |c|
      name, value = c.split(";").first.split("=", 2)
      @cookies[name] = value
    end
  end
end

# ---------------------------------------------------------------------------
# HTML helpers
# ---------------------------------------------------------------------------
def csrf_from_form(body, action_pattern)
  body.scan(/<form([^>]*)>(.*?<\/form>)/m).each do |attrs, content|
    return content[/name="authenticity_token" value="([^"]*)"/, 1] if attrs.match?(action_pattern)
  end
  nil
end

def doorkeeper_error(body)
  body[/<pre>([^<]*)<\/pre>/, 1]&.strip
end

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------
errors = []
session = SandboxSession.new(SANDBOX_URL)

# --- Check 1: Login --------------------------------------------------------
puts "→ Logging in to #{SANDBOX_URL.host}..."

res = session.get("/session/identify")
fail "[validate-sandbox] Cannot reach #{SANDBOX_URL} (HTTP #{res.code})" unless res.code == "200"

csrf = csrf_from_form(res.body, /session\/identify/)
fail "[validate-sandbox] Could not extract CSRF token from /session/identify" if csrf.nil?

res = session.post("/session/identify",
  "authenticity_token" => csrf,
  "session[email]" => EMAIL,
  "session[remember_me]" => "1",
  "commit" => "Continue"
)
unless res.body.include?("session[password]")
  errors << "Step 1 (identify): expected password form but got HTTP #{res.code}"
  res.body[/name="authenticity_token" value="([^"]*)"/] # keep going to report
end

if errors.empty?
  all_csrf = res.body.scan(/name="authenticity_token" value="([^"]*)"/).flatten
  password_csrf = all_csrf[2] || all_csrf.last

  res = session.post("/session",
    "authenticity_token" => password_csrf,
    "session[email]" => EMAIL,
    "session[password]" => PASSWORD,
    "session[remember_me]" => "1",
    "commit" => "Sign in"
  )
  if res.code == "302" && res["location"]&.include?("/my_account")
    puts "  ✓ Login successful"
  else
    errors << "Step 2 (password): expected 302 to /my_account, got #{res.code} → #{res['location']}"
  end
end

# --- Check 2: OAuth client registered ---------------------------------------
if errors.empty?
  puts "→ Validating OAuth client..."

  valid_params = URI.encode_www_form(
    "response_type" => "code",
    "client_id" => CLIENT_ID,
    "redirect_uri" => "bikeindex://",
    "scope" => SCOPE
  )
  res = session.get("/oauth/authorize?#{valid_params}")

  oauth_valid =
    (res.code == "302" && res["location"]&.include?("code=")) ||
    (res.code == "200") # consent page

  if oauth_valid
    puts "  ✓ OAuth client #{CLIENT_ID[0, 8]}… is registered (#{res.code})"
  else
    err = doorkeeper_error(res.body)
    errors << "OAuth valid client: expected 302+code or 200, got #{res.code} #{err}"
  end

  # Invalid client should get 401
  invalid_params = URI.encode_www_form(
    "response_type" => "code",
    "client_id" => "INVALID_CLIENT_000000",
    "redirect_uri" => "bikeindex://",
    "scope" => SCOPE
  )
  res = session.get("/oauth/authorize?#{invalid_params}")
  if res.code == "401"
    puts "  ✓ Invalid client correctly rejected (401)"
  else
    errors << "OAuth invalid client: expected 401, got #{res.code}"
  end
end

# --- Check 3: Sticker present ------------------------------------------------
if errors.empty?
  puts "→ Validating sticker #{STICKER_ID}..."

  res = session.get("/bikes/scanned/#{STICKER_ID}")

  if res.code == "302" && res["location"]&.match?(%r{/bikes/\d})
    puts "  ✓ Sticker #{STICKER_ID} found → #{res['location']}"
  elsif res.code == "302" && res["location"]&.include?("/my_account")
    errors << "Sticker #{STICKER_ID}: not found (redirected to /my_account)"
  else
    errors << "Sticker #{STICKER_ID}: unexpected response #{res.code} → #{res['location']}"
  end
end

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
if errors.any?
  errors.each { |e| warn "[validate-sandbox] ✗ #{e}" }
  abort "[validate-sandbox] #{errors.size} check(s) FAILED"
end

puts "[validate-sandbox] OK: login, OAuth client, and sticker #{STICKER_ID} all valid"
