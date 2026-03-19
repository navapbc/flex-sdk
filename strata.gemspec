# frozen_string_literal: true

require_relative "lib/strata/version"

Gem::Specification.new do |spec|
  spec.name        = "strata"
  spec.version     = Strata::VERSION
  spec.authors     = [ "Strata Team" ]
  spec.email       = [ "strata@example.com" ]
  spec.homepage    = "https://example.com/strata"
  spec.summary     = "Strata SDK for Rails"
  spec.description = "Strata SDK for building government digital services with Rails."

  spec.metadata["allowed_push_host"] = "https://example.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com/strata"
  spec.metadata["changelog_uri"] = "https://example.com/strata/changelog"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.2.2"
  spec.add_dependency "pundit", ">= 2.5.0"
  spec.add_dependency "validates_timeliness", ">= 7.0.0" # Update to 8.0.0 when upgrading to Rails 8.0
  spec.add_dependency "view_component", ">= 4.0.2"
end
