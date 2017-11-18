lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/branch/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-branch'
  spec.version       = Fastlane::Branch::VERSION
  spec.authors       = ['Branch', 'Jimmy Dee']
  spec.email         = ['integrations@branch.io', 'jgvdthree@gmail.com']

  spec.summary       = 'Adds Branch keys, custom URI schemes and domains to iOS and Android projects. ' \
                       'Validates the Universal Link configuration for any Xcode project.'
  spec.homepage      = "https://github.com/BranchMetrics/fastlane-plugin-branch"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'branch_io_cli', '>= 0.12.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-simplecov'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'fastlane', '>= 2.26.1'
end
