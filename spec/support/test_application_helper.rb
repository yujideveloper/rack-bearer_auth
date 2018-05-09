# frozen_string_literal: true

module TestApplicationHelper
  class TestApplication
    def call(_env)
      code   = 200
      body   = ["success"]
      header = { "Content-Type"           => "text/plain; charset=utf-8",
                 "Content-Length"         => body.join("\n").bytesize.to_s,
                 "X-XSS-Protection"       => "1; mode=block",
                 "X-Content-Type-Options" => "nosniff",
                 "X-Frame-Options"        => "SAMEORIGIN" }
      [code, header, body]
    end
  end
end
