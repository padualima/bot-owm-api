source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# HTTP/REST API client library.
gem 'faraday', '~> 2.7'

# Complete Ruby geocoding solution.
gem 'geocoder', '~> 1.8'

# Represent use cases in a simple and powerful way while writing modular.
gem 'u-case', '~> 4.5.1'

# Generate beautiful API documentation
gem 'rswag-api', '~> 2.8'
gem 'rswag-ui', '~> 2.8'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # Use Pry as your rails console
  gem 'pry-rails', '~> 0.3.3'
  # Autoload dotenv in Rails.
  gem 'dotenv-rails', '~> 2.1'
  # rspec-rails is a testing framework for Rails 5+.
  gem 'rspec-rails', '~> 6.0'
  # Set of matchers and helpers to allow you test your APIs responses like a pro.
  gem 'rspec-json_expectations', '~> 2.2'
  # WebMock allows stubbing HTTP requests and setting expectations on HTTP requests.
  gem 'webmock', '~> 3.18'
  # factory_bot_rails provides integration between factory_bot and rails 5.0 or newer
  gem 'factory_bot_rails', '~> 6.2'
  # Simple one-liner tests for common Rails functionality
  gem 'shoulda-matchers', '~> 5.3'
  # Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses..
  gem 'faker', '~> 3.1'
  # Simplify API integration testing with a succinct rspec DSL and generate OpenAPI specification
  gem 'rswag-specs', '~> 2.8'
end
