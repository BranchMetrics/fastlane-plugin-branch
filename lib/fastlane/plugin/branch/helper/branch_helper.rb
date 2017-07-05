require "fastlane/plugin/branch/helper/android_helper"
require "fastlane/plugin/branch/helper/configuration_helper"
require "fastlane/plugin/branch/helper/ios_helper"

module Fastlane
  module Helper
    UI = FastlaneCore::UI

    class BranchHelper
      class << self
        attr_accessor :changes # An array of file paths (Strings) that were modified
        attr_accessor :errors # An array of error messages (Strings) from validation

        include AndroidHelper
        include ConfigurationHelper
        include IOSHelper

        def add_change(change)
          @changes ||= Set.new
          @changes << change.to_s
        end
      end
    end
  end
end
