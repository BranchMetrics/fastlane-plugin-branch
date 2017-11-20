module Fastlane
  module Actions
    class UpdateActionDocsAction < Action
      class << self
        def run(params)
          template = File.read(File.join(Fastlane::ROOT, "lib", "assets", "ActionDetails.md.erb"))
          FileUtils.mkdir_p "doc"

          Dir[File.expand_path(File.join("..", "..", "lib", "fastlane", "plugin", "branch", "actions", "*_action.rb"), __FILE__)]
            .each do |path|
            class_name = File.basename(path, ".rb").split("_").map(&:capitalize).join("")
            @action = Object.const_get("Fastlane").const_get("Actions").const_get(class_name)
            document = ERB.new(template, 0, '-').result binding

            doc_path = File.join("doc", "#{File.basename(path, '.rb')}.md")
            File.write doc_path, document
          end
        end

        def available_options
          []
        end

        def description
          "Generate a standard action page for each action"
        end
      end
    end
  end
end
