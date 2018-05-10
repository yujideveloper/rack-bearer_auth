# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::BearerAuth::Request do
  describe "#initialize" do
    subject { described_class.new(env) }

    context "HTTP_AUTHORIZATION header for bearer auth is specified" do
      let(:env) do
        { "PATH_INFO" => "/foo",
          "REQUEST_METHOD" => "GET",
          "HTTP_AUTHORIZATION" => "Bearer test_token" }
      end

      it { is_expected.to have_attributes path: "/foo", via: :get, token: "test_token" }
    end

    context "HTTP_AUTHORIZATION header for Basic auth is specified" do
      let(:env) do
        { "PATH_INFO" => "/foo",
          "REQUEST_METHOD" => "GET",
          "HTTP_AUTHORIZATION" => "Basic dXNlcjpwYXNzd29yZA==" }
      end

      it { is_expected.to have_attributes path: "/foo", via: :get, token: nil }
    end

    context "HTTP_AUTHORIZATION header is not specified" do
      let(:env) do
        { "PATH_INFO" => "/foo",
          "REQUEST_METHOD" => "GET" }
      end

      it { is_expected.to have_attributes path: "/foo", via: :get, token: nil }
    end
  end

  describe "token pattern" do
    subject { described_class.new(env).token }

    let(:env) do
      { "PATH_INFO" => "/foo",
        "REQUEST_METHOD" => "GET",
        "HTTP_AUTHORIZATION" => "Bearer #{token}" }
    end

    let(:valid_chars) do
      [*"A".."Z", *"a".."z", *"0".."9", "+", "-", ".", "~", "+", "/"]
    end

    context "not ends with `=`" do
      let(:token) do
        valid_chars.shuffle.join
      end

      it { is_expected.to eq token }
    end

    context "ends with single `=`" do
      let(:token) do
        "#{valid_chars.shuffle.join}="
      end

      it { is_expected.to eq token }
    end

    context "ends with multiple `=`" do
      let(:token) do
        "#{valid_chars.shuffle.join}=="
      end

      it { is_expected.to eq token }
    end

    context "starts with `=`" do
      let(:token) do
        "=#{valid_chars.shuffle.join}"
      end

      it { is_expected.to be_nil }
    end

    context "contains with `=`" do
      let(:token) do
        last_index = valid_chars.size - 1
        insert_pos = Range.new(1, last_index, true).to_a.sample
        valid_chars.shuffle.insert(insert_pos, "=")
      end

      it { is_expected.to be_nil }
    end

    context "containts with invalid char" do
      let(:token) do
        last_index = valid_chars.size - 1
        insert_pos = Range.new(1, last_index, true).to_a.sample
        valid_chars.shuffle.insert(insert_pos, ",")
      end

      it { is_expected.to be_nil }
    end
  end
end
