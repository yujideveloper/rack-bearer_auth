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
        match_token?(req) ? :ok : :invalid_token
      end

      private

      def match_route?(req)
        match_path?(req) && match_via?(req)
      end

      def match_path?(req)
        case path
        when nil
          true
        when String
          path == req.path
        when Regexp
          !(path =~ req.path).nil?
        when Proc
          path.call(req.path)
        when Array
          path.any? { match_path?(req) }
        else
          raise "Unsupported path pattern"
        end
      end

      def match_via?(req)
        case via
        when nil, :all
          true
        when String
          via == req.via
        when Regexp
          !(via =~ req.via).nil?
        when Proc
          via.call(req.via)
        when Array
          via.any? { match_via?(req) }
        else
          raise "Unsupported via pattern"
        end
      end

      def match_token?(req)
        case token
        when nil
          true
        when String
          token == req.token
        when Regexp
          !(token =~ req.token).nil?
        when Proc
          token.call(req.token)
        when Array
          token.any? { match_token?(req) }
        else
          raise "Unsupported token pattern"
        end
      end
    end
  end
end
