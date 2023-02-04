# frozen_string_literal: true

require_relative "lib/toottown/version"

Gem::Specification.new do |spec|
  spec.name          = "toottown"
  spec.version       = Toottown::VERSION
  spec.author        = "Bridgetown Team"
  spec.email         = "maintainers@bridgetownrb.com"
  spec.summary       = "Sample code for creating new Bridgetown plugins"
  spec.homepage      = "https://github.com/username/toottown"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|script|spec|features|frontend)/!) }
  spec.test_files    = spec.files.grep(%r!^test/!)
  spec.require_paths = ["lib"]
  # Uncomment this if you wish to supply a companion NPM package:
  # spec.metadata      = { "yarn-add" => "toottown@#{Toottown::VERSION}" }

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency "bridgetown", ">= 1.2.0", "< 2.0"
  spec.add_dependency "phlex", "~> 1.3"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rubocop-bridgetown", "~> 0.3"
  spec.add_development_dependency "dotenv", "~> 2.8"
end
