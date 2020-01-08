# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/bearer_auth/version"

Gem::Specification.new do |spec|
  spec.name          = "rack-bearer_auth"
  spec.version       = Rack::BearerAuth::VERSION
  spec.authors       = ["Yuji Hanamura"]
  spec.email         = ["yuji.developer@gmail.com"]

  spec.summary       = "Middleware for using RFC 6750 bearer auth in Rack apps"
  spec.description   = "Middleware for using RFC 6750 bearer auth in Rack apps"
  spec.homepage      = "https://github.com/yujideveloper/rack-bearer_auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "pry", ">= 0.10.0"
  spec.add_development_dependency "pry-byebug", ">= 3.6.0"
  spec.add_development_dependency "rack-test", "~> 1.0.0"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", ">= 0.61.1"
end
