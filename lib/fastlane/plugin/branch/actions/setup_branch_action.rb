require "xcodeproj"

module Fastlane
  module Actions
    class SetupBranchAction < Action
      def self.run(params)
        helper = Helper::BranchHelper

        live_key = params[:live_key]
        test_key = params[:test_key]

        # raises unless :live_key or :test_key is present
        # (used with :app_link_subdomain to choose which domains to add)
        domains = helper.domains_from_params params

        if params[:xcodeproj].nil? and params[:android_project_path].nil?
          raise ":xcodeproj or :android_project_path is required"
        end

        UI.message "live key: #{live_key}" unless live_key.nil?
        UI.message "test key: #{test_key}" unless test_key.nil?
        UI.message "domains: #{domains}"

        keys = {}
        keys[:live] = live_key unless live_key.nil?
        keys[:test] = test_key unless test_key.nil?

        if params[:xcodeproj]
          # raises
          xcodeproj = Xcodeproj::Project.open params[:xcodeproj]

          if params[:update_bundle_and_team_ids]
            helper.update_team_and_bundle_ids_from_aasa_file xcodeproj, domains.first
          elsif helper.validate_team_and_bundle_ids_from_aasa_files xcodeproj, domains
            UI.message "Universal Link configuration passed validation. ✅"
          else
            UI.error "Universal Link configuration failed validation."
            helper.errors.each { |error| UI.error " #{error}" }
            return
          end

          # the following calls can all raise IOError
          helper.add_keys_to_info_plist xcodeproj, keys
          helper.add_universal_links_to_project xcodeproj, domains, params[:remove_existing_domains]
          xcodeproj.save
        end

        if params[:android_project_path]
          project_path = params[:android_project_path]
          manifest = File.open("#{project_path}/app/src/main/AndroidManifest.xml") { |f| Nokogiri::XML f }

          helper.add_keys_to_android_manifest manifest, keys
          # :activity_name and :uri_scheme may be nil. :remove_existing_domains defaults to false
          helper.add_intent_filters_to_android_manifest manifest,
                                                        domains,
                                                        params[:uri_scheme],
                                                        params[:activity_name],
                                                        params[:remove_existing_domains]

          File.open("#{project_path}/app/src/main/AndroidManifest.xml", "w") do |f|
            manifest.write_xml_to f, ident: 4
          end
        end
      rescue => e
        UI.user_error! "Error in SetupBranchAction: #{e.message}"
      end

      def self.description
        "Adds Branch keys, custom URI schemes and domains to iOS and Android projects."
      end

      def self.authors
        ["Jimmy Dee"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "More to come"
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
                                 is_string: false)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
        # [:ios, :android].contains platform # Add Android once available
      end
    end
  end
end
