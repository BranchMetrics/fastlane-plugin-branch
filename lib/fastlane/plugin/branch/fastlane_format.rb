require "branch_io_cli/format"

module Fastlane
  module Branch
    module FastlaneFormat
      include BranchIOCLI::Format
      def option(opt)
        if opt =~ /^no_/
          opt_text = "#{opt.to_s.sub(/^no_/, '')}: false"
        else
          opt_text = opt.to_s
        end
        highlight opt_text
      end
    end

    module FastlaneMarkdownFormat
      include BranchIOCLI::Format::MarkdownFormat
      include FastlaneFormat

      def local_render(template)
        path = File.expand_path(File.join("..", "..", "..", "..", "..", "assets", "templates", "#{template}.erb"), __FILE__)
        ERB.new(File.read(path)).result binding
      end

      def table_option(option)
        "|#{option.name}|#{option.description}|#{option.env_name}|#{option.type ? 'Boolean' : option.type}|#{option.default_value}|"
      end
    end

    module FastlaneDescriptionFormat
      include FastlaneFormat

      def highlight(text)
        text
      end

      def italics(text)
        text
      end

      def header(text, level = 1)
        "#{text}: "
      end
    end
  end
end
