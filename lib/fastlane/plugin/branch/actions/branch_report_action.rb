require "branch_io_cli"
require "fastlane/plugin/branch/config_item"
require "fastlane/plugin/branch/fastlane_format"

include Fastlane::Branch::FastlaneDescriptionFormat

module Fastlane
  module Actions
    class BranchReportAction < Action
      def self.run(params)
        config = BranchIOCLI::Configuration::ReportConfiguration.wrapper params, false
        BranchIOCLI::Commands::ReportCommand.new(config).run!
      rescue StandardError => e
        UI.user_error! "Error in BranchReportAction: #{e.message}\n#{e.backtrace}"
      end

      def self.description
        "TODO"
      end

      def self.authors
        [
          "Branch <integrations@branch.io>",
          "Jimmy Dee <jgvdthree@gmail.com>"
        ]
      end

      def self.details
        render :report_description
      end

      def self.example_code
        [
        ]
      end

      def self.available_options
        BranchIOCLI::Configuration::ReportConfiguration.available_options.map do |option|
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
