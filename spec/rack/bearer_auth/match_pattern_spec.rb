# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::BearerAuth::MatchPattern do
  describe "#initialize" do
    subject { described_class.new(path, via, token) }

    let(:path) { "/foo" }
    let(:via) { :all }

    context "with token argument" do
      let(:token) { "test_token" }

      it { is_expected.to have_attributes path: path, via: via, token: token }
    end

    context "without token argument" do
      let(:token) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
