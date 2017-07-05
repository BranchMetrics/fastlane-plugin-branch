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
    end
  end
end
