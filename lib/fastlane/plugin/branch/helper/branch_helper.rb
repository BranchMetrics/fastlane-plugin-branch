require "fastlane/plugin/branch/helper/android_helper"
require "fastlane/plugin/branch/helper/configuration_helper"
require "fastlane/plugin/branch/helper/ios_helper"

module Fastlane
  module Helper
    UI = FastlaneCore::UI

    class BranchHelper
      class << self
        attr_accessor :errors
        include AndroidHelper
        include ConfigurationHelper
        include IOSHelper
      end
    end
  end
end
