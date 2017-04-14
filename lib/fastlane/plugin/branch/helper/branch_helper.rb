module Fastlane
  module Helper
    class BranchHelper
      class << self
        # Converts params[:domains] to an Array of Strings or nil if no
        # :domains key. params[:domains] may be an Array or a comma-separated String,
        # which is converted to an Array of Strings. Raises if params[:domain] is
        # a different type. Assumes params non-nil.
        #
        # :params: Fastlane Action params passed to SetupBranchAction.run
        def domains_from_params(params)
          domains = params[:domains]
          return nil if params[:domains].nil?

          if domains.kind_of? Array
            domains = domains.map(&:to_s)
          elsif domains.kind_of? String
            domains = domains.split(",")
          else
            raise "Unsupported type #{domains.class.name} for :domains key"
          end

          domains
        end
      end
    end
  end
end
