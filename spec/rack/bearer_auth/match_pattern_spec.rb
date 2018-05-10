# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::BearerAuth::MatchPattern do
  describe "#initialize" do
    subject { described_class.new(path, via, token) }

    let(:path) { "/foo" }
    let(:via) { :all }

    context "with token argument" do
      let(:token) { "test_token" }

      it { expect { subject }.not_to raise_error }
    end

    context "without token argument" do
      let(:token) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe "attribute readers" do
    let(:match_pattern) { described_class.new(path, via, token) }
    let(:path) { "/foo" }
    let(:via) { :all }
    let(:token) { "test_token" }

    describe "#path" do
      subject { match_pattern.path }

      it { is_expected.to be_instance_of described_class::Path }
      it { expect(subject.pattern).to eq path }
    end

    describe "#via" do
      subject { match_pattern.via }

      it { is_expected.to be_instance_of described_class::Via }
      it { expect(subject.pattern).to eq via }
    end

    describe "#token" do
      subject { match_pattern.token }

      it { is_expected.to be_instance_of described_class::Token }
      it { expect(subject.pattern).to eq token }
    end
  end

  describe "#match" do
    subject { match_pattern.match(request) }

    let(:match_pattern) do
      described_class.new(path, via, token)
    end
    let(:path) { "/foo" }
    let(:via) { :get }
    let(:token) { "test_token" }
    let(:request_class) do
      Struct.new(:path, :via, :token)
    end

    context "match" do
      let(:request) { request_class.new(path, via, token) }

      it { is_expected.to eq :ok }
    end

    context "mismatch path" do
      let(:request) { request_class.new("/bar", via, token) }

      it { is_expected.to eq :skip }
    end

    context "mismatch via" do
      let(:request) { request_class.new(path, :post, token) }

      it { is_expected.to eq :skip }
    end

    context "empty token" do
      let(:request) { request_class.new(path, via, nil) }

      it { is_expected.to eq :token_required }
    end

    context "mismatch token" do
      let(:request) { request_class.new(path, via, "mismatch_token") }

      it { is_expected.to eq :invalid_token }
    end
  end

  describe Rack::BearerAuth::MatchPattern::Path do
    describe "#match?" do
      subject { pattern.match?(path) }

      let(:path) { "/foo" }

      context "nil" do
        let(:pattern) { described_class.new(nil) }

        it { is_expected.to eq true }
      end

      context "String" do
        context "match pattern" do
          let(:pattern) { described_class.new("/foo") }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new("/bar") }

          it { is_expected.to eq false }
        end
      end

      context "Regexp" do
        context "match pattern" do
          let(:pattern) { described_class.new(%r{\A/f..\z}) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(%r{\A/b..\z}) }

          it { is_expected.to eq false }
        end
      end

      context "Proc" do
        context "match pattern" do
          let(:pattern) { described_class.new(->(p) { p == "/foo" }) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(->(p) { p == "/bar" }) }

          it { is_expected.to eq false }
        end
      end

      context "Array" do
        context "match pattern" do
          let(:pattern) { described_class.new(%w[/foo /bar]) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(%w[/bar /baz]) }

          it { is_expected.to eq false }
        end
      end
    end
  end

  describe Rack::BearerAuth::MatchPattern::Via do
    describe "#match?" do
      subject { pattern.match?(via) }

      let(:via) { :get }

      context "nil" do
        let(:pattern) { described_class.new(nil) }

        it { is_expected.to eq true }
      end

      context ":all" do
        let(:pattern) { described_class.new(:all) }

        it { is_expected.to eq true }
      end

      context "String" do
        context "match pattern" do
          let(:pattern) { described_class.new("get") }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new("post") }

          it { is_expected.to eq false }
        end
      end

      context "Symbol" do
        context "match pattern" do
          let(:pattern) { described_class.new(:get) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(:post) }

          it { is_expected.to eq false }
        end
      end

      context "Regexp" do
        context "match pattern" do
          let(:pattern) { described_class.new(/\A(get|post)\z/) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(/\A(post|delete)\z/) }

          it { is_expected.to eq false }
        end
      end

      context "Proc" do
        context "match pattern" do
          let(:pattern) { described_class.new(->(p) { p == :get }) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(->(p) { p == :post }) }

          it { is_expected.to eq false }
        end
      end

      context "Array" do
        context "match pattern" do
          let(:pattern) { described_class.new(%i[get post]) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(%w[post delete]) }

          it { is_expected.to eq false }
        end
      end
    end
  end

  describe Rack::BearerAuth::MatchPattern::Token do
    describe "#match?" do
      subject { pattern.match?(token) }

      let(:token) { "test_token" }

      context "nil" do
        let(:pattern) { described_class.new(nil) }

        it { is_expected.to eq true }
      end

      context "String" do
        context "match pattern" do
          let(:pattern) { described_class.new("test_token") }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new("mismatch_token") }

          it { is_expected.to eq false }
        end
      end

      context "Regexp" do
        context "match pattern" do
          let(:pattern) { described_class.new(/\A.*_token\z/) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(/\Amismatch_.*\z/) }

          it { is_expected.to eq false }
        end
      end

      context "Proc" do
        context "match pattern" do
          let(:pattern) { described_class.new(->(p) { p == "test_token" }) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(->(p) { p == "mismatch_token" }) }

          it { is_expected.to eq false }
        end
      end

      context "Array" do
        context "match pattern" do
          let(:pattern) { described_class.new(%w[test_token mismatch_token]) }

          it { is_expected.to eq true }
        end

        context "mismatch pattern" do
          let(:pattern) { described_class.new(%w[mismatch_token unmatch_token]) }

          it { is_expected.to eq false }
        end
      end
    end
  end
end
