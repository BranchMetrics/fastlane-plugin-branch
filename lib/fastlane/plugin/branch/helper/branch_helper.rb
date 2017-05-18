require "nokogiri"
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

        def domains_from_params(params)
          app_link_subdomains = app_link_subdomains_from_params params
          custom_domains = custom_domains_from_params params
          domains = (app_link_subdomains + custom_domains).uniq
          raise ArgumentError, ":app_link_subdomain or :domains is required" if domains.empty?
          domains
        end

        def app_link_subdomains_from_params(params)
          app_link_subdomain = params[:app_link_subdomain]
          live_key = params[:live_key]
          test_key = params[:test_key]
          raise ArgumentError, ":live_key or :test_key is required" if live_key.nil? and test_key.nil?

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

        def add_keys_to_info_plist(project, keys, configuration = RELEASE_CONFIGURATION)
          # find the first application target
          target = project.targets.find { |t| !t.extension_target_type? && !t.test_target_type? }

          raise "No application target found" if target.nil?

          # find the Info.plist paths for all configurations
          info_plist_paths = target.resolved_build_setting "INFOPLIST_FILE"

          raise "INFOPLIST_FILE not found in target" if info_plist_paths.nil? or info_plist_paths.empty?

          # this can differ from one configuration to another.
          info_plist_path = info_plist_paths[configuration]

          raise "Info.plist not found for configuration #{configuration}" if info_plist_path.nil?

          project_parent = File.dirname project.path

          info_plist_path = File.join project_parent, info_plist_path

          # try to open and parse the Info.plist (raises)
          info_plist = Plist.parse_xml info_plist_path

          # add/overwrite Branch key(s)
          info_plist["branch_key"] = keys

          Plist::Emit.save_plist info_plist, info_plist_path
        end

        def add_universal_links_to_project(project, domains, remove_existing, configuration = RELEASE_CONFIGURATION)
          # find the first application target
          target = project.targets.find { |t| !t.extension_target_type? && !t.test_target_type? }

          raise "No application target found" if target.nil?

          # TODO: Handle different configurations
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
            entitlements = Plist.parse_xml entitlements_path
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

        def update_team_and_bundle_ids_from_aasa_file(project, domain)
          # raises
          identifiers = app_ids_from_aasa_file domain
          raise "Multiple appIDs found in AASA file" if identifiers.count > 1

          identifier = identifiers[0]
          team, bundle = team_and_bundle_from_app_id identifier

          update_team_and_bundle_ids project, team, bundle
        end

        def validate_team_and_bundle_ids_from_aasa_files(project, domains, configuration = RELEASE_CONFIGURATION)
          @errors = []
          valid = false # one domain must validate
          domains.each do |domain|
            # ignore test-app.link domains for now (bnctestbed.test-app.link/apple-app-site-association is blank)
            # TODO: Support URI schemes for iOS?
            next if domain =~ /\.test-app\.link$/
            domain_valid = validate_team_and_bundle_ids project, domain, configuration
            valid ||= domain_valid
            UI.message "Valid Universal Link configuration for #{domain} ✅" if domain_valid
          end
          valid
        end

        def app_ids_from_aasa_file(domain)
          file = JSON.parse Net::HTTP.get(domain, "/apple-app-site-association")
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

        def validate_team_and_bundle_ids(project, domain, configuration)
          target = project.targets.find { |t| !t.extension_target_type? && !t.test_target_type? }

          raise "No application target found" if target.nil?

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

        def add_keys_to_android_manifest(project_path, live_key, test_key)
          manifest = File.open("#{project_path}/app/src/main/AndroidManifest.xml") { |f| Nokogiri::XML f }

          # TODO: Work on formatting
          unless live_key.nil?
            live_key_element = manifest.at_css('manifest application meta-data[android|name="io.branch.sdk.BranchKey"]')
            if live_key_element.nil?
              application = manifest.at_css('manifest application')
              application.add_child "  <meta-data android:name=\"io.branch.sdk.BranchKey\" android:value=\"#{live_key}\" />\n  "
            else
              live_key_element["android:value"] = live_key
            end
          end

          unless test_key.nil?
            test_key_element = manifest.at_css('manifest application meta-data[android|name="io.branch.sdk.BranchKey.test"]')
            if test_key_element.nil?
              application = manifest.at_css('manifest application')
              application.add_child "  <meta-data android:name=\"io.branch.sdk.BranchKey\" android:value=\"#{live_key}\" />\n  "
            else
              test_key_element["android:value"] = live_key
            end
          end

          File.open("#{project_path}/app/src/main/AndroidManifest.xml", "w") do |f|
            manifest.write_xml_to f, ident: 4
          end
        end
      end
    end
  end
end
