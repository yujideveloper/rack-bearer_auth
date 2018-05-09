# frozen_string_literal: true

module Rack
  module BearerAuth
    class Request
      # https://tools.ietf.org/html/rfc6750#section-2.1
      # b64token    = 1*( ALPHA / DIGIT /
      #                   "-" / "." / "_" / "~" / "+" / "/" ) *"="
      # credentials = "Bearer" 1*SP b64token
      BEARER_TOKEN_REGEXP = %r{\ABearer ([A-Za-z0-9\-._~+/]+=*)\z}

      attr_reader :path, :via, :token

      def initialize(env)
        @path = env["PATH_INFO"]
        @via = env["REQUEST_METHOD"]

        authz = env["HTTP_AUTHORIZATION"]
        @token = Regexp.last_match(1) if authz&.match(BEARER_TOKEN_REGEXP)
      end
    end
  end
end
