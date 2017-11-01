require "branch_io_cli"

module Fastlane
  module Actions
    class SetupBranchAction < Action
      def self.run(params)
        params.load_configuration_file "Branchfile"
        options = Helper::BranchOptions.new params
        BranchIOCLI::Commands::SetupCommand.new(options).run!
      rescue StandardError => e
        UI.user_error! "Error in SetupBranchAction: #{e.message}\n#{e.backtrace}"
      end

      def self.description
        "Adds Branch keys, custom URI schemes and domains to iOS and Android projects."
      end

      def self.authors
        [
          "Branch <integrations@branch.io>",
          "Jimmy Dee <jgvdthree@gmail.com>"
        ]
      end

      def self.details
        "This action automatically configures Xcode projects that use the Branch SDK " \
          "for Universal Links and custom URI handling. It modifies Xcode project settings and " \
          "entitlements as well as Info.plist files. It also validates the Universal Link " \
          "configuration for Xcode projects."
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
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "BRANCH_XCODEPROJ",
                               description: "Path to an Xcode project to modify",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :live_key,
                                  env_name: "BRANCH_LIVE_KEY",
                               description: "The Branch live key for your app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :test_key,
                                  env_name: "BRANCH_TEST_KEY",
                               description: "The Branch test key for your app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :domains,
                                  env_name: "BRANCH_DOMAINS",
                               description: "Branch (and/or non-Branch) Universal Link/App Link domains to add (comma-separated list or array)",
                                  optional: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :app_link_subdomain,
                                  env_name: "BRANCH_APP_LINK_SUBDOMAIN",
                               description: "app.link subdomain",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :uri_scheme,
                                  env_name: "BRANCH_URI_SCHEME",
                               description: "Custom URI scheme used with Branch",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "BRANCH_TARGET",
                               description: "Name of the target in the Xcode project to modify (iOS only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :validate,
                                  env_name: "BRANCH_VALIDATE",
                               description: "Determines whether to validate the resulting Universal Link configuration before modifying the project",
                             default_value: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :force,
                                  env_name: "BRANCH_FORCE_UPDATE",
                               description: "Update project(s) even if Universal Link validation fails",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :commit,
                                  env_name: "BRANCH_COMMIT_CHANGES",
                               description: "Set to true to commit changes to Git; set to a string to commit with a custom message",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :frameworks,
                                  env_name: "BRANCH_FRAMEWORKS",
                               description: "A list of system frameworks to add to the target that uses the Branch SDK (iOS only)",
                                  optional: true,
                             default_value: [],
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :add_sdk,
                                  env_name: "BRANCH_ADD_SDK",
                               description: "Set to false to disable automatic integration of the Branch SDK",
                                  optional: true,
                             default_value: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :podfile,
                                  env_name: "BRANCH_PODFILE",
                               description: "Path to a Podfile to update (iOS only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :patch_source,
                                  env_name: "BRANCH_PATCH_SOURCE",
                               description: "Set to false to disable automatic source-code patching",
                                  optional: true,
                             default_value: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :pod_repo_update,
                                  env_name: "BRANCH_POD_REPO_UPDATE",
                               description: "Set to false to disable update of local podspec repo before pod install",
                                  optional: true,
                             default_value: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :cartfile,
                                  env_name: "BRANCH_CARTFILE",
                               description: "Path to a Cartfile to update (iOS only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :carthage_command,
                                  env_name: "BRANCH_CARTHAGE_COMMAND",
                               description: "Command to use when installing with Carthage",
                                  optional: true,
                             default_value: "update --platform ios",
                                      type: String)
        ]
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
