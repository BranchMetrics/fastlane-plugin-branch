source 'https://rubygems.org'

gemspec

# for example app
gem "cocoapods"
gem "fastlane", path: "../../jdee/fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
