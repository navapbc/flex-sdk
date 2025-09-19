source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in strata.gemspec.
gemspec name: "strata"

gem "puma"

gem "sprockets-rails"

# Authorization
gem "pundit"

gem "validates_timeliness", ">= 7.0.0"


# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

group :development, :test do
  gem "pg", "~> 1.1"
  gem "guard-rspec", require: false
  gem "rspec-rails", "~> 7.0.0"
  gem "shoulda-matchers", "~> 6.0"
  gem "faker"
  gem "dotenv"
  gem "rails-controller-testing"

  # Lookbook
  gem "lookbook", ">= 2.3.9"

  gem "factory_bot_rails"
end

group :development do
  # Linting
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-yard", require: false

  # Hot reloading for Lookbook
  gem "listen"
  gem "actioncable"
end

group :test do
  gem "simplecov", require: false
  gem "capybara"
  gem "temporary_tables", require: false
  gem "pundit-matchers"
end

gem "debug", "~> 1.11", groups: [ :test, :development ]
