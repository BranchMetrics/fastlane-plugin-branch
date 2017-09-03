module Fastlane
  module Helper
    module ConfigurationHelper
      def keys_from_params(params)
        live_key = params[:live_key]
        test_key = params[:test_key]
        keys = {}
        keys[:live] = live_key unless live_key.nil?
        keys[:test] = test_key unless test_key.nil?
        keys
      end

      def xcodeproj_path_from_params(params)
        return params[:xcodeproj] if params[:xcodeproj]

        # Adapted from commit_version_bump
        # https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/commit_version_bump.rb#L21

        # This may not be a git project. Search relative to the Gemfile.
        repo_path = Bundler.root

        all_xcodeproj_paths = Dir[File.expand_path(File.join(repo_path, '**/*.xcodeproj'))]
        # find an xcodeproj (ignoring the Cocoapods one)
        xcodeproj_paths = Fastlane::Actions.ignore_cocoapods_path(all_xcodeproj_paths)

        # no projects found: error
        UI.user_error!('Could not find a .xcodeproj in the current repository\'s working directory.') and return nil if xcodeproj_paths.count == 0

        # too many projects found: error
        if xcodeproj_paths.count > 1
          repo_pathname = Pathname.new repo_path
          relative_projects = xcodeproj_paths.map { |e| Pathname.new(e).relative_path_from(repo_pathname).to_s }.join("\n")
          UI.user_error!("Found multiple .xcodeproj projects in the current repository's working directory. Please specify your app's main project: \n#{relative_projects}")
          return nil
        end

        # one project found: great
        xcodeproj_paths.first
      end

      def domains_from_params(params)
        app_link_subdomains = app_link_subdomains_from_params params
        custom_domains = custom_domains_from_params params
        (app_link_subdomains + custom_domains).uniq
      end

      def app_link_subdomains_from_params(params)
        app_link_subdomain = params[:app_link_subdomain]
        live_key = params[:live_key]
        test_key = params[:test_key]
        return [] if live_key.nil? and test_key.nil?
        return [] if app_link_subdomain.nil?

        domains = []
        unless live_key.nil?
          domains += [
            "#{app_link_subdomain}.app.link",
            "#{app_link_subdomain}-alternate.app.link"
          ]
        end
        unless test_key.nil?
          domains += [
            "#{app_link_subdomain}.test-app.link",
            "#{app_link_subdomain}-alternate.test-app.link"
          ]
        end
        domains
      end

      def custom_domains_from_params(params)
        domains = params[:domains]
        return [] if domains.nil?

        if domains.kind_of? Array
          domains = domains.map(&:to_s)
        elsif domains.kind_of? String
          domains = domains.split(",")
        else
          raise ArgumentError, "Unsupported type #{domains.class.name} for :domains key"
        end

        domains
      end

      def podfile_path_from_params(params)
        # Disable Podfile update if add_sdk: false is present
        return nil unless add_sdk? params

        # Use the :podfile parameter if present
        if params[:podfile]
          UI.user_error! ":podfile argument must specify a path ending in '/Podfile'" unless params[:podfile] =~ %r{/Podfile$}
          podfile_path = File.expand_path params[:podfile], Bundler.root
          return podfile_path if File.exist? podfile_path
          UI.user_error! "#{podfile_path} not found"
        end

        xcodeproj_path = xcodeproj_path_from_params(params)
        # Look in the same directory as the project (typical setup)
        podfile_path = File.expand_path "../Podfile", xcodeproj_path
        return podfile_path if File.exist? podfile_path
      end

      def cartfile_path_from_params(params)
        # Disable Cartfile update if add_sdk: false is present
        return nil unless add_sdk? params

        # Use the :cartfile parameter if present
        if params[:cartfile]
          UI.user_error! ":cartfile argument must specify a path ending in '/Cartfile'" unless params[:cartfile] =~ %r{/Cartfile$}
          cartfile_path = File.expand_path params[:cartfile], Bundler.root
          return cartfile_path if File.exist? cartfile_path
          UI.user_error! "#{cartfile_path} not found"
        end

        xcodeproj_path = xcodeproj_path_from_params(params)
        # Look in the same directory as the project (typical setup)
        cartfile_path = File.expand_path "../Cartfile", xcodeproj_path
        return cartfile_path if File.exist? cartfile_path
      end

      def add_sdk?(params)
        add_sdk_param = params[:add_sdk]
        return false if add_sdk_param.nil?

        case add_sdk_param
        when String
          add_sdk_param.casecmp? "true"
        else
          add_sdk_param
        end
      end
    end
  end
end
