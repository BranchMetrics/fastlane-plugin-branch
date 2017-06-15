require "nokogiri"
require "pathname"
require "plist"

module Fastlane
  module Helper
    UI = FastlaneCore::UI
    class BranchHelper
      APPLINKS = "applinks"
      ASSOCIATED_DOMAINS = "com.apple.developer.associated-domains"
      CODE_SIGN_ENTITLEMENTS = "CODE_SIGN_ENTITLEMENTS"
      DEVELOPMENT_TEAM = "DEVELOPMENT_TEAM"
      PRODUCT_BUNDLE_IDENTIFIER = "PRODUCT_BUNDLE_IDENTIFIER"
      RELEASE_CONFIGURATION = "Release"

      class << self
        attr_accessor :errors

        #
        # ----- Configuration -----
        #

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

        #
        # ----- iOS Support -----
        #

        def add_keys_to_info_plist(project, target_name, keys, configuration = RELEASE_CONFIGURATION)
          # raises
          target = target_from_project project, target_name

          # find the Info.plist paths for all configurations
          info_plist_paths = target.resolved_build_setting "INFOPLIST_FILE"

          raise "INFOPLIST_FILE not found in target" if info_plist_paths.nil? or info_plist_paths.empty?

          # this can differ from one configuration to another.
          info_plist_path = info_plist_paths[configuration]

          raise "Info.plist not found for configuration #{configuration}" if info_plist_path.nil?

          project_parent = File.dirname project.path

          info_plist_path = File.join project_parent, info_plist_path

          # try to open and parse the Info.plist (raises)
          info_plist = File.open(info_plist_path) { |f| Plist.parse_xml f }
          raise "Failed to parse #{info_plist_path}" if info_plist.nil?

          # add/overwrite Branch key(s)
          if keys.count > 1
            info_plist["branch_key"] = keys
          elsif keys[:live]
            info_plist["branch_key"] = keys[:live]
          else # no need to validate here, which was done by the action
            info_plist["branch_key"] = keys[:test]
          end

          Plist::Emit.save_plist info_plist, info_plist_path
        end

        def add_universal_links_to_project(project, target_name, domains, remove_existing, configuration = RELEASE_CONFIGURATION)
          # raises
          target = target_from_project project, target_name

          relative_entitlements_path = target.resolved_build_setting(CODE_SIGN_ENTITLEMENTS)[configuration]
          project_parent = File.dirname project.path

          if relative_entitlements_path.nil?
            relative_entitlements_path = File.join target.name, "#{target.name}.entitlements"
            entitlements_path = File.join project_parent, relative_entitlements_path

            # Add CODE_SIGN_ENTITLEMENTS setting to each configuration
            target.build_configuration_list.set_setting CODE_SIGN_ENTITLEMENTS, relative_entitlements_path

            # Add the file to the project
            project.new_file relative_entitlements_path

            entitlements = {}
            current_domains = []
          else
            entitlements_path = File.join project_parent, relative_entitlements_path
            # Raises
            entitlements = File.open(entitlements_path) { |f| Plist.parse_xml f }
            raise "Failed to parse entitlements file #{entitlements_path}" if entitlements.nil?

            if remove_existing
              current_domains = []
            else
              current_domains = entitlements[ASSOCIATED_DOMAINS]
            end
          end

          current_domains += domains.map { |d| "#{APPLINKS}:#{d}" }
          all_domains = current_domains.uniq

          entitlements[ASSOCIATED_DOMAINS] = all_domains

          Plist::Emit.save_plist entitlements, entitlements_path
        end

        def team_and_bundle_from_app_id(identifier)
          team = identifier.sub(/\..+$/, "")
          bundle = identifier.sub(/^[^.]+\./, "")
          [team, bundle]
        end

        def update_team_and_bundle_ids_from_aasa_file(project, target_name, domain)
          # raises
          identifiers = app_ids_from_aasa_file domain
          raise "Multiple appIDs found in AASA file" if identifiers.count > 1

          identifier = identifiers[0]
          team, bundle = team_and_bundle_from_app_id identifier

          update_team_and_bundle_ids project, target_name, team, bundle
        end

        def validate_team_and_bundle_ids_from_aasa_files(project, target_name, domains = [], configuration = RELEASE_CONFIGURATION)
          @errors = []
          valid = true

          # Include any domains already in the project.
          # Raises. Returns an non-nil array of strings.
          all_domains = (domains + domains_from_project(project, target_name, configuration)).uniq
          if all_domains.empty?
            # Cannot get here from SetupBranchAction, since the domains passed in will never be empty.
            # If called from ValidateUniversalLinksAction, this is a failure, possibly caused by
            # failure to add applinks:.
            @errors << "No Universal Link domains in project. Be sure each Universal Link domain is prefixed with applinks:."
            return false
          end

          all_domains.each do |domain|
            # ignore test-app.link domains for now (bnctestbed.test-app.link/apple-app-site-association is blank)
            # TODO: Support URI schemes for iOS?
            next if domain =~ /\.test-app\.link$/
            domain_valid = validate_team_and_bundle_ids project, target_name, domain, configuration
            valid &&= domain_valid
            UI.message "Valid Universal Link configuration for #{domain} ✅" if domain_valid
          end
          valid
        end

        def app_ids_from_aasa_file(domain)
          # raises
          file = JSON.parse contents_of_aasa_file domain

          applinks = file[APPLINKS]
          @errors << "No #{APPLINKS} found in AASA file for domain #{domain}" and return if applinks.nil?

          details = applinks["details"]
          @errors << "No details found for #{APPLINKS} in AASA file for domain #{domain}" and return if details.nil?

          identifiers = details.map { |d| d["appID"] }.uniq
          @errors << "No appID found in AASA file for domain #{domain}" and return if identifiers.count <= 0
          identifiers
        rescue JSON::ParserError => e
          @errors << "Failed to parse AASA file for domain #{domain}: #{e.message}"
          nil
        end

        def contents_of_aasa_file(domain)
          uris = [
            URI("https://#{domain}/.well-known/apple-app-site-association"),
            URI("https://#{domain}/apple-app-site-association")
          ]

          data = nil

          uris.each do |uri|
            break unless data.nil?

            Net::HTTP.start uri.host, uri.port, use_ssl: uri.scheme == "https" do |http|
              request = Net::HTTP::Get.new uri
              response = http.request request

              # Try the next URI.
              unless response.code.to_i == 200
                UI.message "Could not retrieve #{uri}: #{response.code} #{response.message}. Ignoring."
                next
              end

              content_type = response["Content-type"]
              raise "Response does not contain a Content-type header" if content_type.nil?

              case content_type
              when %r{application/pkcs7-mime}
                # Verify/decrypt PKCS7 (non-Branch domains)
                cert_store = OpenSSL::X509::Store.new
                signature = OpenSSL::PKCS7.new response.body
                # raises
                signature.verify [http.peer_cert], cert_store, nil, OpenSSL::PKCS7::NOVERIFY
                data = signature.data
              else
                data = response.body
              end

              UI.message "Retrieved contents of #{uri} ✅"
            end
          end

          raise "Failed to retrieve AASA file for #{domain}" if data.nil?

          data
        end

        def validate_team_and_bundle_ids(project, target_name, domain, configuration)
          # raises
          target = target_from_project project, target_name

          product_bundle_identifier = target.resolved_build_setting(PRODUCT_BUNDLE_IDENTIFIER)[configuration]
          development_team = target.resolved_build_setting(DEVELOPMENT_TEAM)[configuration]

          identifiers = app_ids_from_aasa_file domain
          return false if identifiers.nil?

          app_id = "#{development_team}.#{product_bundle_identifier}"
          match_found = identifiers.include? app_id

          unless match_found
            @errors << "appID mismatch for #{domain}. Project: #{app_id}. AASA: #{identifiers}"
          end

          match_found
        end

        def validate_project_domains(expected, project, target, configuration = RELEASE_CONFIGURATION)
          @errors = []
          project_domains = domains_from_project project, target, configuration
          valid = expected.count == project_domains.count
          if valid
            sorted = expected.sort
            project_domains.sort.each_with_index do |domain, index|
              valid = false and break unless sorted[index] == domain
            end
          end

          unless valid
            @errors << "Project domains do not match :domains parameter"
            @errors << "Project domains: #{project_domains}"
            @errors << ":domains parameter: #{expected}"
          end

          valid
        end

        def update_team_and_bundle_ids(project, team, bundle)
          # find the first application target
          target = project.targets.find { |t| !t.extension_target_type? && !t.test_target_type? }

          raise "No application target found" if target.nil?

          target.build_configuration_list.set_setting PRODUCT_BUNDLE_IDENTIFIER, bundle
          target.build_configuration_list.set_setting DEVELOPMENT_TEAM, team

          # also update the team in the first test target
          target = project.targets.find(&:test_target_type?)
          return if target.nil?

          target.build_configuration_list.set_setting DEVELOPMENT_TEAM, team
        end

        def target_from_project(project, target_name)
          if target_name
            target = project.targets.find { |t| t.name == target_name }
            raise "Target #{target} not found" if target.nil?
          else
            # find the first application target
            target = project.targets.find { |t| !t.extension_target_type? && !t.test_target_type? }
            raise "No application target found" if target.nil?
          end
          target
        end

        def domains_from_project(project, target_name, configuration = RELEASE_CONFIGURATION)
          # Raises. Does not return nil.
          target = target_from_project project, target_name

          relative_entitlements_path = target.resolved_build_setting(CODE_SIGN_ENTITLEMENTS)[configuration]
          return [] if relative_entitlements_path.nil?

          project_parent = File.dirname project.path
          entitlements_path = File.join project_parent, relative_entitlements_path

          # Raises
          entitlements = File.open(entitlements_path) { |f| Plist.parse_xml f }
          raise "Failed to parse entitlements file #{entitlements_path}" if entitlements.nil?

          entitlements[ASSOCIATED_DOMAINS].select { |d| d =~ /^applinks:/ }.map { |d| d.sub(/^applinks:/, "") }
        end

        #
        # ----- Android support -----
        #

        def add_keys_to_android_manifest(manifest, keys)
          add_metadata_to_manifest manifest, "io.branch.sdk.BranchKey", keys[:live] unless keys[:live].nil?
          add_metadata_to_manifest manifest, "io.branch.sdk.BranchKey.test", keys[:test] unless keys[:test].nil?
        end

        # TODO: Work on all XML/AndroidManifest formatting

        def add_metadata_to_manifest(manifest, key, value)
          element = manifest.at_css "manifest > application > meta-data[android|name=\"#{key}\"]"
          if element.nil?
            application = manifest.at_css "manifest application"
            application.add_child "    <meta-data android:name=\"#{key}\" android:value=\"#{value}\" />\n"
          else
            element["android:value"] = value
          end
        end

        def add_intent_filters_to_android_manifest(manifest, domains, uri_scheme, activity_name, remove_existing)
          if activity_name
            activity = manifest.at_css "manifest > application > activity[android|name=\"#{activity_name}\""
          else
            activity = find_activity manifest
          end

          raise "Failed to find an Activity in the Android manifest" if activity.nil?

          if remove_existing
            remove_existing_domains(activity)
          end

          add_intent_filter_to_activity activity, domains, uri_scheme
        end

        def find_activity(manifest)
          # try to infer the right activity
          # look for the first singleTask
          single_task_activity = manifest.at_css "manifest > application > activity[android|launchMode=\"singleTask\"]"
          return single_task_activity if single_task_activity

          # no singleTask activities. Take the first Activity
          # TODO: Add singleTask?
          manifest.at_css "manifest > application > activity"
        end

        def add_intent_filter_to_activity(activity, domains, uri_scheme)
          # Add a single intent-filter with autoVerify and a data element for each domain and the optional uri_scheme
          intent_filter = <<-EOF

            <intent-filter android:autoverify="true">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                #{app_link_data_elements domains}
                #{uri_scheme_data_element uri_scheme}
            </intent-filter>
          EOF
          intent_filter += " " * 8
          activity.add_child intent_filter
        end

        def remove_existing_domains(activity)
          # Find all intent-filters that include a data element with android:scheme
          # TODO: Can this be done with a single css/at_css call?
          activity.css("intent-filter").each do |filter|
            filter.remove if filter.at_css "data[android|scheme]"
          end
        end

        def app_link_data_elements(domains)
          domains.map { |d| "<data android:scheme=\"https\" android:host=\"#{d}\"/>" }.join("\n" + " " * 16)
        end

        def uri_scheme_data_element(uri_scheme)
          return "" if uri_scheme.nil?

          "<data android:scheme=\"#{uri_scheme}\" android:host=\"open\"/>"
        end
      end
    end
  end
end
