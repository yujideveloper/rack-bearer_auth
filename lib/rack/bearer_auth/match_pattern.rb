# frozen_string_literal: true

module Rack
  module BearerAuth
    class MatchPattern
      attr_reader :path, :via, :token

      def initialize(path, via, token)
        raise ArgumentError, "Token pattern is required" unless token

        @path = Path.new(path)
        @via = Via.new(via)
        @token = Token.new(token)
      end

      def match(req)
        return :skip unless match_route?(req)
        return :token_required unless req.token

        token.match?(req.token) ? :ok : :invalid_token
      end

      private

      def match_route?(req)
        path.match?(req.path) && via.match?(req.via)
      end

      class Base
        attr_reader :pattern

        def initialize(pattern)
          @pattern = pattern
        end

        def match?(*)
          raise ::NotImplementedError
        end

        def self.new(*)
          if self == Base
            raise ::NotImplementedError,
                  "#{self} is an abstract class and cannot be instantiated."
          end
          super
        end
      end

      class Path < Base
        def match?(path)
          _match?(self.pattern, path)
        end

        private

        def _match?(path_pattern, path_value) # rubocop:disable Metrics/MethodLength
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
            path_pattern.any? { |pattern| _match?(pattern, path_value) }
          else
            raise "Unsupported path pattern"
          end
        end
      end

      class Via < Base
        def match?(via)
          _match?(self.pattern, via)
        end

        private

        def _match?(via_pattern, via_value) # rubocop:disable Metrics/MethodLength
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
            via_pattern.any? { |pattern| _match?(pattern, via_value) }
          else
            raise "Unsupported via pattern"
          end
        end
      end

      class Token < Base
        def match?(token)
          _match?(self.pattern, token)
        end

        private

        def _match?(token_pattern, token_value) # rubocop:disable Metrics/MethodLength
          case token_pattern
          when String
            token_pattern == token_value
          when Regexp
            !(token_pattern =~ token_value).nil?
          when Proc
            token_pattern.call(token_value)
          when Array
            token_pattern.any? { |pattern| _match?(pattern, token_value) }
          else
            raise "Unsupported token pattern"
          end
        end
      end
    end
  end
end
