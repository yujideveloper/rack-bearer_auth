# frozen_string_literal: true

module Rack
  module BearerAuth
    class MatchPattern
      attr_reader :path, :via, :token

      def initialize(path, via, token)
        raise ArgumentError, "Token pattern is required" unless token

        @path = path
        @via = via
        @token = token
      end

      def match(req)
        return :skip unless match_route?(req)
        return :token_required unless req.token
        match_token?(self.token, req.token) ? :ok : :invalid_token
      end

      private

      def match_route?(req)
        match_path?(self.path, req.path) && match_via?(self.via, req.via)
      end

      def match_path?(path_pattern, path_value)
        case path_pattern
        when nil
          true
        when String
          path_pattern == path_value
        when Regexp
          !(path_pattern =~ path_value).nil?
        when Proc
          path_pattern.call(path_value)
        when Array
          path_pattern.any? { |pattern| match_path?(pattern, path_value) }
        else
          raise "Unsupported path pattern"
        end
      end

      def match_via?(via_pattern, via_value)
        case via_pattern
        when nil, :all
          true
        when Symbol, String
          via_pattern.to_sym == via_value
        when Regexp
          !(via_pattern =~ via_value).nil?
        when Proc
          via_pattern.call(via_value)
        when Array
          via_pattern.any? { |pattern| match_via?(pattern, via_value) }
        else
          raise "Unsupported via pattern"
        end
      end

      def match_token?(token_pattern, token_value)
        case token_pattern
        when nil
          true
        when String
          token_pattern == token_value
        when Regexp
          !(token_pattern =~ token_value).nil?
        when Proc
          token_pattern.call(token_value)
        when Array
          token_pattern.any? { |pattern| match_token?(pattern, token_value) }
        else
          raise "Unsupported token pattern"
        end
      end
    end
  end
end
