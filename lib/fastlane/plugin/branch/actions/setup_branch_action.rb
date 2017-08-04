require "rexml/document"
require "xcodeproj"

module Fastlane
  module Actions
    class SetupBranchAction < Action
      # rubocop: disable Metrics/PerceivedComplexity
      def self.run(params)
        # First augment with any defaults from Branchfile, if present
        params.load_configuration_file("Branchfile")

        helper = Helper::BranchHelper

        keys = helper.keys_from_params params
        raise "Must specify :live_key or :test_key." if keys.empty?

        domains = helper.domains_from_params params
        raise "Cannot determine domains to add to project. Specify :app_link_subdomain or :domains." if domains.empty?

        if params[:xcodeproj].nil? and params[:android_project_path].nil? and params[:android_manifest_path].nil?
          raise ":xcodeproj, :android_manifest_path or :android_project_path is required"
        end

        UI.message "live key: #{keys[:live]}" unless keys[:live].nil?
        UI.message "test key: #{keys[:test]}" unless keys[:test].nil?
        UI.message "domains: #{domains}"

        if params[:xcodeproj]
          # raises
          xcodeproj = Xcodeproj::Project.open params[:xcodeproj]

          target = params[:target] # may be nil

          if params[:update_bundle_and_team_ids]
            helper.update_team_and_bundle_ids_from_aasa_file xcodeproj, target, domains.first
          elsif helper.validate_team_and_bundle_ids_from_aasa_files xcodeproj, target, domains, params[:remove_existing_domains]
            UI.message "Universal Link configuration passed validation. ✅"
          else
            UI.error "Universal Link configuration failed validation."
            helper.errors.each { |error| UI.error " #{error}" }
            return unless params[:force]
          end

          # the following calls can all raise IOError
          helper.add_keys_to_info_plist xcodeproj, target, keys
          helper.add_branch_universal_link_domains_to_info_plist xcodeproj, target, domains
          new_path = helper.add_universal_links_to_project xcodeproj, target, domains, params[:remove_existing_domains]
          other_action.git_add path: new_path if params[:commit] && new_path
          xcodeproj.save
        end

        if params[:android_project_path] || params[:android_manifest_path]
          # :android_manifest_path overrides :android_project_path
          manifest_path = params[:android_manifest_path] || "#{params[:android_project_path]}/app/src/main/AndroidManifest.xml"
          manifest = File.open(manifest_path) { |f| REXML::Document.new f }

          helper.add_keys_to_android_manifest manifest, keys
          # :activity_name and :uri_scheme may be nil. :remove_existing_domains defaults to false
          helper.add_intent_filters_to_android_manifest manifest,
                                                        domains,
                                                        params[:uri_scheme],
                                                        params[:activity_name],
                                                        params[:remove_existing_domains]

          File.open(manifest_path, "w") do |f|
            manifest.write f, 4
          end

          helper.add_change File.expand_path(manifest_path, Bundler.root)
        end

        if params[:commit]
          message = params[:commit].kind_of?(String) ? params[:commit] : "[Fastlane] Branch SDK integration"
          other_action.git_commit path: helper.changes.to_a, message: message
        end
      rescue => e
        UI.user_error! "Error in SetupBranchAction: #{e.message}\n#{e.backtrace}"
      end
      # rubocop: enable Metrics/PerceivedComplexity

      def self.description
        "Adds Branch keys, custom URI schemes and domains to iOS and Android projects."
      end

      def self.authors
        [
          "Branch <integrations@branch.io>",
          "Jimmy Dee <jgvdthree@gmail.com>"
        ]
      end

      def self.details
        "This action automatically configures Xcode and Android projects that use the Branch SDK " \
          "for Universal Links, App Links and custom URI handling. It modifies Xcode project settings and " \
          "entitlements as well as Info.plist and AndroidManifest.xml files. It also validates the Universal Link " \
          "configuration for Xcode projects."
      end

      def self.example_code
        [
          <<-EOF
            setup_branch live_key: "key_live_xxxx",
                         test_key: "key_test_yyyy",
               app_link_subdomain: "myapp",
                       uri_scheme: "myscheme", # Android only
             android_project_path: "MyAndroidApp", # MyAndroidApp/src/main/AndroidManifest.xml
                        xcodeproj: "MyIOSApp.xcodeproj"
          EOF
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "BRANCH_XCODEPROJ",
                               description: "Path to an Xcode project to modify",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :android_project_path,
                                  env_name: "BRANCH_ANDROID_PROJECT_PATH",
                               description: "Path to an Android project to modify",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :android_manifest_path,
                                  env_name: "BRANCH_ANDROID_MANIFEST_PATH",
                               description: "Path to and Android manifest to modify",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :live_key,
                                  env_name: "BRANCH_LIVE_KEY",
                               description: "The Branch live key for your app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :test_key,
                                  env_name: "BRANCH_TEST_KEY",
                               description: "The Branch test key for your app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :domains,
                                  env_name: "BRANCH_DOMAINS",
                               description: "Branch (and/or non-Branch) Universal Link/App Link domains to add (comma-separated list or array)",
                                  optional: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :app_link_subdomain,
                                  env_name: "BRANCH_APP_LINK_SUBDOMAIN",
                               description: "app.link subdomain",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :uri_scheme,
                                  env_name: "BRANCH_URI_SCHEME",
                               description: "Custom URI scheme used with Branch (Android only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :activity_name,
                                  env_name: "BRANCH_ACTIVITY_NAME",
                               description: "Name of the Activity in the manifest containing Branch intent-filers (Android only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "BRANCH_TARGET",
                               description: "Name of the target in the Xcode project to modify (iOS only)",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :update_bundle_and_team_ids,
                                  env_name: "BRANCH_UPDATE_BUNDLE_AND_TEAM_IDS",
                               description: "If set to true, updates the bundle and team identifiers to match the AASA file (iOS only)",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :remove_existing_domains,
                                  env_name: "BRANCH_REMOVE_EXISTING_DOMAINS",
                               description: "If set to true, removes any existing domains before adding Branch domains",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :force,
                                  env_name: "BRANCH_FORCE_UPDATE",
                               description: "Update project(s) even if Universal Link validation fails",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :commit,
                                  env_name: "BRANCH_COMMIT_CHANGES",
                               description: "Set to true to commit changes to Git; set to a string to commit with a custom message",
                                  optional: true,
                             default_value: false,
                                 is_string: false)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include? platform
      end

      def self.category
        :project
      end
    end
  end
end
