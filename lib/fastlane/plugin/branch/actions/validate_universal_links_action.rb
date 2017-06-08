require "xcodeproj"

module Fastlane
  module Actions
    class ValidateUniversalLinksAction < Action
      def self.run(params)
        helper = Fastlane::Helper::BranchHelper

        xcodeproj_path = helper.xcodeproj_path_from_params params
        # Error reporting is done in the helper.
        return false if xcodeproj_path.nil?

        # raises
        xcodeproj = Xcodeproj::Project.open xcodeproj_path

        target = params[:target] # may be nil

        if helper.validate_team_and_bundle_ids_from_aasa_files xcodeproj, target
          UI.message "Universal Link configuration passed validation. ✅"
          return true
        else
          UI.user_error! "Universal Link configuration failed validation"
          return false
        end
      rescue => e
        UI.user_error! "Error in SetupBranchAction: #{e.message}"
        return false
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
            validate_universal_links xcodeproj: "MyProject.xcodeproj"
          EOF,
          <<-EOF
            validate_universal_links xcodeproj: "MyProject.xcodeproj", target: "MyProject"
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
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "BRANCH_TARGET",
                               description: "Name of the target in the Xcode project to modify (iOS only)",
                                  optional: true,
                                      type: String)
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
