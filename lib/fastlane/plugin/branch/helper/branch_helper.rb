module Fastlane
  module Helper
    class BranchHelper
      # class methods that you define here become available in your action
      # as `Helper::BranchHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the branch plugin helper!")
      end
    end
  end
end
