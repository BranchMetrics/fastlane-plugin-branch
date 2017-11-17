source 'https://rubygems.org'

gemspec

# for example app
gem "branch_io_cli", path: "../branch_io_cli"
gem "cocoapods"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
