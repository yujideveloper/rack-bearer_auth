# Rack::BearerAuth

Rack::BearerAuth is middleware that make using [RFC 6750](https://tools.ietf.org/html/rfc6750) bearer auth in Rack apps.

[![Build Status](https://travis-ci.org/yujideveloper/rack-bearer_auth.svg?branch=master)](https://travis-ci.org/yujideveloper/rack-bearer_auth)
[![Maintainability](https://api.codeclimate.com/v1/badges/db47f9a4e48bd30edb98/maintainability)](https://codeclimate.com/github/yujideveloper/rack-bearer_auth/maintainability)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-bearer_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-bearer_auth

## Configuration

### Rsils configuration

``` ruby
module YourApp
  class Application < Rails::Application

    # ...

    config.middleware.use, Rack::BearerAuth::Middleware do
      match path: "/foo" do |token|
        # validate token
      end

      match via: :all do |token|
        # validate token
      end

      match path: "/bar", via: %i[post patch delete], token: "some_token"
    end
  end
end
```

### Rack configuration

``` ruby
use Rack::BearerAuth::Middleware do
  match path: "/foo" do |token|
    # validate token
  end

  match via: :all do |token|
    # validate token
  end

  match path: "/bar", via: %i[post patch delete], token: "some_token"
end

```

#E Restrictions

* [Form-Encoded Body Parameter(RFC 6750 section 2.2)](https://tools.ietf.org/html/rfc6750#section-2.2) is not supported.
* [URI Query Parameter(RFC 6750 section 2.3)](https://tools.ietf.org/html/rfc6750#section-2.3) is not supported.
* `scope` attribute is not supported.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yujideveloper/rack-bearer_auth.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
