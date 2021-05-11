# frozen_string_literal: true

require_relative "request"
require_relative "match_pattern"

module Rack
  module BearerAuth
    class Middleware
      def initialize(app, &block)
        raise ArgumentError, "Block argument is required." unless block_given?
        raise ArgumentError, "Block argument can only accept 0 or 1 arguments." unless block.arity <= 1

        @app = app
        @match_patterns = []

        # original block handler
        instance_exec(&block) if block.arity == 0

        # token based block handler
        match(&block) if block.arity == 1
      end

      def call(env)
        req = Request.new(env)

        handle(req) || @app.call(env)
      end

      def match(path: nil, via: nil, token: nil, &block)
        if block_given?
          warn "Token paramter is ignored." if token
          token = block
        end

        @match_patterns << MatchPattern.new(path, via, token)
      end

      private

      def handle(req) # rubocop:disable Metrics/MethodLength
        @match_patterns.each do |pattern|
          case pattern.match(req)
          when :skip
            next
          when :ok
            break
          when :token_required
            return [401,
                    { "WWW-Authenticate" => 'Bearer realm="token_required"',
                      "Content-Type"     => "text/plain; charset=utf-8",
                      "Content-Length"   => "0" },
                    []]
          when :invalid_token
            return [401,
                    { "WWW-Authenticate" => 'Bearer error="invalid_token"',
                      "Content-Type"     => "text/plain; charset=utf-8",
                      "Content-Length"   => "0" },
                    []]
          else
            warn "A pattern is ignored."
          end
        end
        nil
      end
    end
  end
end
