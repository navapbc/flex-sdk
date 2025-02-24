require_relative "lib/flex_sdk/version"

Gem::Specification.new do |spec|
  spec.name        = "flex_sdk"
  spec.version     = FlexSdk::VERSION
  spec.authors     = [ "" ]
  spec.email       = [ "" ]
  spec.homepage    = "https://example.com/benefits_sdk"
  spec.summary     = ""
  spec.description = "Application Engine"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com/benefits_sdk"
  spec.metadata["changelog_uri"] = "https://example.com/benefits_sdk"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
end
