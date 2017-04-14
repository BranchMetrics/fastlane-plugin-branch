module Fastlane
  module Actions
    class BranchAction < Action
      def self.run(params)
        UI.message("The branch plugin is working!")
      end

      def self.description
        "Adds Branch keys, custom URI schemes and domains to iOS and Android projects."
      end

      def self.authors
        ["Jimmy Dee"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "More to come"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "BRANCH_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
