require "branch_io_cli"

module Fastlane
  module Actions
    class ValidateUniversalLinksAction < Action
      def self.run(params)
        options = Helper::BranchOptions.new params
        BranchIOCLI::Commands::ValidateCommand.new(options).run!
      rescue StandardError => e
        UI.user_error! "Error in ValidateUniversalLinksAction: #{e.message}\n#{e.backtrace}"
        false
      end

      def self.description
        "Validates Universal Link configuration for an Xcode project."
      end

      def self.authors
        [
          "Branch <integrations@branch.io>",
          "Jimmy Dee <jgvdthree@gmail.com>"
        ]
      end

      def self.details
        "This action validates all the Universal Link domains found in an Xcode project's entitlements " \
        "file by ensuring that the development team and bundle identifier combination is found in the " \
        "domain's apple-app-site-association file."
      end

      def self.example_code
        [
          <<-EOF
            validate_universal_links
          EOF,
          <<-EOF
            validate_universal_links(xcodeproj: "MyProject.xcodeproj")
          EOF,
          <<-EOF
            validate_universal_links(xcodeproj: "MyProject.xcodeproj", target: "MyProject")
          EOF,
          <<-EOF
            validate_universal_links(domains: %w{example.com www.example.com})
          EOF
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "BRANCH_XCODEPROJ",
                               description: "Path to an Xcode project to validate",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "BRANCH_TARGET",
                               description: "Name of the target in the Xcode project to validate",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :domains,
                                  env_name: "BRANCH_DOMAINS",
                               description: "Branch (and/or non-Branch) Universal Link/App Link domains expected to be present in project (comma-separated list or array)",
                                  optional: true,
                                 is_string: false)
        ]
      end

      def self.return_value
        "Returns true for a valid configuration, false otherwise."
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.category
        :project
      end
    end
  end
end
