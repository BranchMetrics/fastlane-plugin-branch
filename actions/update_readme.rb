require "fastlane/plugin/branch/fastlane_format"

module Fastlane
  module Actions
    class UpdateReadmeAction < Action
      class << self
        include Fastlane::Branch::FastlaneMarkdownFormat

        def run(params)
          [SetupBranchAction, ValidateUniversalLinksAction, BranchReportAction].inject("") do |docs, action|
            @action = action

            if action == SetupBranchAction
              @command = BranchIOCLI::Command::SetupCommand
            elsif action == ValidateUniversalLinksAction
              @command = BranchIOCLI::Command::ValidateCommand
            elsif action == BranchReportAction
              @command = BranchIOCLI::Command::ReportCommand
            end

            docs + local_render(:action)
          end
        end

        def description
          "Update the contents of the README in this repo"
        end
      end
    end
  end
end
