# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Rack::BearerAuth do
  include TestApplicationHelper
  include Rack::Test::Methods

  describe "#initialize" do
    let(:test_app) do
      test_app = TestApplicationHelper::TestApplication.new
    end

    context "with block argument" do
      subject do
        Rack::BearerAuth::Middleware.new(test_app) do
        end
      end

      it { expect { subject }.not_to raise_error }
    end

    context "without block argument" do
      subject do
        Rack::BearerAuth::Middleware.new(test_app)
      end

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe "GET /foo" do
    subject do
      get "/foo"
      last_response
    end

    context "with empty pattern" do
      let(:app) do
        test_app = TestApplicationHelper::TestApplication.new
        Rack::BearerAuth::Middleware.new(test_app) {}
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

    context "with match pattern" do
      let(:app) do
        test_app = TestApplicationHelper::TestApplication.new
        Rack::BearerAuth::Middleware.new(test_app) do
          match path: "/foo", token: "test_token"
        end
      end

      context "requests with match token" do
        it "should returns 200 OK" do
          header "Authorization", "Bearer test_token"
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

      context "requests with mismatch token" do
        it "should returns 401 Unauthorized" do
          header "Authorization", "Bearer mismatch_token"
          expect(subject).to have_attributes(
            status: 401,
            body:   "",
            header: a_hash_including(
              "Content-Type"     => "text/plain; charset=utf-8",
              "Content-Length"   => "0",
              "WWW-Authenticate" => 'Bearer error="invalid_token"'
            )
          )
        end
      end

      context "requests without token" do
        it "should returns 401 Unauthorized" do
          expect(subject).to have_attributes(
            status: 401,
            body:   "",
            header: a_hash_including(
              "Content-Type"     => "text/plain; charset=utf-8",
              "Content-Length"   => "0",
              "WWW-Authenticate" => 'Bearer realm="token_required"'
            )
          )
        end
      end
    end

    context "with mismatch pattern" do
      let(:app) do
        test_app = TestApplicationHelper::TestApplication.new
        Rack::BearerAuth::Middleware.new(test_app) do
          match path: "/bar", token: "test_token"
        end
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

    context "with multple patterns" do
      let(:app) do
        test_app = TestApplicationHelper::TestApplication.new
        Rack::BearerAuth::Middleware.new(test_app) do
          match path: "/foo", token: "test_token1"
          match path: "/bar", token: "test_token2"
        end
      end

      context "requests with match token" do
        it "should returns 200 OK" do
          header "Authorization", "Bearer test_token1"
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
  end
end
