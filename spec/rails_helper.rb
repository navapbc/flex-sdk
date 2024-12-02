# Load the Rails environment for the engine
ENGINE_ROOT = File.expand_path("../..", __FILE__)
require File.expand_path("#{ENGINE_ROOT}/test/dummy/config/environment.rb", __FILE__)

# Load RSpec Rails
require 'rspec/rails'

# Additional RSpec configuration
RSpec.configure do |config|
  # Disable fixtures
  config.fixture_path = nil if config.respond_to?(:fixture_path=)

  # Infer spec types from file location
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces
  config.filter_rails_from_backtrace!
end