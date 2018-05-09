# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::BearerAuth do
  it "has a version number" do
    expect(Rack::BearerAuth::VERSION).not_to be nil
  end
end
