module FastlaneCore
  class ConfigItem
    class << self
      def from_branch_option(option)
        new(
          key: option.name,
          env_name: option.env_name,
          description: option.description,
          default_value: option.default_value,
          type: option.type
        )
      end
    end
  end
end
