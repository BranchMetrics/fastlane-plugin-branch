module Fastlane
  module Helper
    class BranchOptions
      attr_reader :params

      # :param: params [FastlaneCore::Configuration] Params from an action
      def initialize(params)
        @params = params
      end

      def method_missing(method_sym, *arguments, &block)
        return params[method_sym]
      end
    end
  end
end
