require "nokogiri"

module Fastlane
  module Helper
    module AndroidHelper
      def add_keys_to_android_manifest(manifest, keys)
        add_metadata_to_manifest manifest, "io.branch.sdk.BranchKey", keys[:live] unless keys[:live].nil?
        add_metadata_to_manifest manifest, "io.branch.sdk.BranchKey.test", keys[:test] unless keys[:test].nil?
      end

      # TODO: Work on all XML/AndroidManifest formatting

      def add_metadata_to_manifest(manifest, key, value)
        element = manifest.at_xpath "//manifest/application/meta-data[@android:name=\"#{key}\"]"
        if element.nil?
          application = manifest.at_xpath "//manifest/application"
          application.add_child "    <meta-data android:name=\"#{key}\" android:value=\"#{value}\" />\n"
        else
          element["android:value"] = value
        end
      end

      def add_intent_filters_to_android_manifest(manifest, domains, uri_scheme, activity_name, remove_existing)
        if activity_name
          activity = manifest.at_xpath "//manifest/application/activity[@android:name=\"#{activity_name}\""
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
        single_task_activity = manifest.at_xpath "//manifest/application/activity[@android:launchMode=\"singleTask\"]"
        return single_task_activity if single_task_activity

        # no singleTask activities. Take the first Activity
        # TODO: Add singleTask?
        manifest.at_xpath "//manifest/application/activity"
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
        activity.xpath("//manifest//intent-filter").each do |filter|
          filter.remove if filter.at_xpath "data[@android:scheme]"
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
