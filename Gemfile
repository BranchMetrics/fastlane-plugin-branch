source 'https://rubygems.org'

gemspec

# for example app
gem "cocoapods"

gem "rspec-simplecov"
gem "simplecov"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
