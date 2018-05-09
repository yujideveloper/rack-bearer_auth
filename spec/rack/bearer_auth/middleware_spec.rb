# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Rack::BearerAuth do
  include TestApplicationHelper
  include Rack::Test::Methods

  let(:app) do
    test_app = TestApplicationHelper::TestApplication.new
    Rack::BearerAuth::Middleware.new(test_app)
  end

  describe "GET /foo" do
    subject do
      get "/foo"
      last_response
    end

    it "should returns 200 OK" do
      expect(subject).to have_attributes(
        status: 200,
        body:   "success",
        header: a_hash_including(
          "Content-Type"           => "text/plain; charset=utf-8",
          "Content-Length"         => "7",
          "X-XSS-Protection"       => "1; mode=block",
          "X-Content-Type-Options" => "nosniff",
          "X-Frame-Options"        => "SAMEORIGIN"
        )
      )
    end
  end
end
