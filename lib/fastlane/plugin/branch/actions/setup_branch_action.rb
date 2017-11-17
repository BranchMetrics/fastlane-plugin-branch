require "branch_io_cli"

include BranchIOCLI::Format::HighlineFormat # for now

module FastlaneCore
  class ConfigItem
    class << self
      def from_branch_option(option)
        params = {
          key: option.name,
          description: option.description,
          default_value: option.default_value,
          type: option.type,
          is_string: option.type == String
        }

        if option.respond_to?(:env_name) && option.env_name
          params[:env_name] = option.env_name
        end

        new params
      end
    end
  end
end

module Fastlane
  module Actions
    class SetupBranchAction < Action
      def self.run(params)
        params.load_configuration_file "Branchfile"
        # second arg false: Don't add default values or env. vars. Let Fastlane
        # handle that. This is necessary to work with the Branchfile.
        config = BranchIOCLI::Configuration::SetupConfiguration.wrapper params, false
        BranchIOCLI::Commands::SetupCommand.new(config).run!
      rescue StandardError => e
        UI.user_error! "Error in SetupBranchAction: #{e.message}\n#{e.backtrace}"
      end

      def self.description
        "This action automatically configures Xcode projects that use the Branch SDK " \
          "for Universal Links and custom URI handling. It modifies Xcode project settings and " \
          "entitlements as well as Info.plist files. It also validates the Universal Link " \
          "configuration for Xcode projects."
      end

      def self.authors
        [
          "Branch <integrations@branch.io>",
          "Jimmy Dee <jgvdthree@gmail.com>"
        ]
      end

      def self.details
        render :setup_description
      end

      def self.example_code
        [
          <<-EOF
            setup_branch(
              live_key: "key_live_xxxx",
              test_key: "key_test_yyyy",
              app_link_subdomain: "myapp",
              uri_scheme: "myscheme",
              xcodeproj: "MyIOSApp.xcodeproj"
            )
          EOF
        ]
      end

      def self.available_options
        BranchIOCLI::Configuration::SetupConfiguration.available_options.map do |option|
          FastlaneCore::ConfigItem.from_branch_option(option)
        end
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
