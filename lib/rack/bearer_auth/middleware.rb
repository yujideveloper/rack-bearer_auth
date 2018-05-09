# frozen_string_literal: true

module Rack
  module BearerAuth
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        # TODO: some handling
        @app.call(env)
      end
    end
  end
end
