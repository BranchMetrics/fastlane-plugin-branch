# branch plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg?style=flat-square)](https://rubygems.org/gems/fastlane-plugin-branch)
[![Gem](https://img.shields.io/gem/v/fastlane-plugin-branch.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-branch)
[![Downloads](https://img.shields.io/gem/dt/fastlane-plugin-branch.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-branch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/settings-bundle/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/BranchMetrics/fastlane-plugin-branch.svg)](https://circleci.com/gh/BranchMetrics/fastlane-plugin-branch)

## Preliminary release

This is a preliminary release of this plugin. Please report any problems by opening issues in this repo.

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-branch`, add it to your project by running:

```bash
fastlane add_plugin branch
```

## setup_branch action

### Prerequisites

Before using this action, make sure to set up your app in the [Branch Dashboard](https://dashboard.branch.io). See https://dev.branch.io/basic-setup/ for details. To use the `setup_branch` action, you need:

- Branch key(s), either live, test or both
- Domain name(s) used for Branch links
- The custom URI scheme for your app, if any (Android only)
- Location(s) of your Android and/or iOS project(s)

### Usage

This action automatically configures Xcode and Android projects that use the Branch SDK
for Universal Links, App Links and custom URI handling. It modifies Xcode project settings and entitlements as well as Info.plist and AndroidManifest.xml files.

```ruby
setup_branch(
  live_key: "key_live_xxxx",
  test_key: "key_test_yyyy",
  app_link_subdomain: "myapp",
  uri_scheme: "myscheme", # Android only
  android_project_path: "MyAndroidApp", # MyAndroidApp/src/main/AndroidManifest.xml
  xcodeproj: "MyIOSApp.xcodeproj"
)
```

Use the `:domains` parameter to specify custom domains, including non-Branch domains
```ruby
setup_branch(
  live_key: "key_live_xxxx",
  domains: %w{example.com www.example.com}
  xcodeproj: "MyIOSApp.xcodeproj"
)
```

Available options:

|Fastfile key|Environment variable|description|type|default value|
|---|---|---|---|---|
|:live_key|BRANCH_LIVE_KEY|The Branch live key to use (:live_key or :test_key is required)|string||
|:test_key|BRANCH_TEST_KEY|The Branch test key to use (:live_key or :test_key is required)|string||
|:app_link_subdomain|BRANCH_APP_LINK_SUBDOMAIN|An app.link subdomain to use (:app_link_subdomain or :domains is required. The union of the two sets of domains will be used.)|string||
|:domains|BRANCH_DOMAINS|A list of domains (custom domains or Branch domains) to use (:app_link_subdomain or :domains is required. The union of the two sets of domains will be used.)|string array or comma-separated string||
|:uri_scheme|BRANCH_URI_SCHEME|A URI scheme to add to the manifest (Android only)|string||
|:android_project_path|BRANCH_ANDROID_PROJECT_PATH|Path to an Android project to use. Equivalent to 'android_manifest_path: "app/src/main/AndroidManifest.xml"`. Overridden by :android_manifest_path (:xcodeproj, :android_project_path or :android_manifest_path is required.)|string||
|:android_manifest_path|BRANCH_ANDROID_MANIFEST_PATH|Path to an Android manifest to modify. Overrides :android_project_path. (:xcodeproj, :android_project_path or :android_manifest_path is required.)|string||
|:xcodeproj|BRANCH_XCODEPROJ|Path to a .xcodeproj directory to use. (:xcodeproj, :android_project_path or :android_manifest_path is required.)|string||
|:activity_name|BRANCH_ACTIVITY_NAME|Name of the Activity to use (Android only; optional)|string||
|:target|BRANCH_TARGET|Name of the target to use in the Xcode project (iOS only; optional)|string||
|:update_bundle_and_team_ids|BRANCH_UPDATE_BUNDLE_AND_TEAM_IDS|If true, changes the bundle and team identifiers in the Xcode project to match the AASA file. Mainly useful for sample apps. (iOS only)|boolean|false|
|:remove_existing_domains|BRANCH_REMOVE_EXISTING_DOMAINS|If true, any domains currently configured in the Xcode project or Android manifest will be removed before adding the domains specified by the arguments. Mainly useful for sample apps.|boolean|false|
|:force|BRANCH_FORCE_UPDATE|Update project(s) even if Universal Link validation fails|boolean|false|
|:commit|BRANCH_COMMIT_CHANGES|Set to true to commit changes to Git; set to a string to commit with a custom message|boolean or string|false|

Individually, all parameters are optional, but the following conditions apply:

- :android_manifest_path, :android_project_path or :xcodeproj must be specified.
- :live_key or :test_key must be specified.
- :app_link_subdomain or :domains must be specified.

This action also supports an optional Branchfile to specify configuration options.
See the sample Branchfile at the root of this repo.

## validate_universal_links action (iOS only)

This action validates all Universal Link domains configured in a project without making any modification.
It validates both Branch and non-Branch domains.


```ruby
validate_universal_links
```

```ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj")
```

```ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj", target: "MyProject")
```

```ruby
validate_universal_links(domains: %w{example.com www.example.com})
```

Available options:

|Fastfile key|Environment variable|description|type|default value|
|---|---|---|---|---|
|:xcodeproj|BRANCH_XCODEPROJ|Path to a .xcodeproj directory to use|string||
|:target|BRANCH_TARGET|Name of the target to use in the Xcode project|string||
|:domains|BRANCH_DOMAINS|A list of domains (custom domains or Branch domains) that must be present in the project.|string array or comma-separated string||

All parameters are optional. Without any parameters, the action looks for a single .xcodeproj
folder (with the exception of a Pods project) and reports an error if none or more than one is found.
It uses the first non-test, non-extension target in that project.

If the :domains parameter is not provided, validation will pass as long as there is at least
one Universal Link domain configured for the target, and all Universal Link domains pass
AASA validation. If the the :domains parameter is provided, the Universal Link domains in
the project must also match the value of this parameter without regard to order.

This action does not use the Branchfile.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. To try it:

```bash
bundle install
bundle exec fastlane validate          # The example project needs to be set up. This will fail.
bundle exec fastlane update            # Also validates the UL configuration.
bundle exec fastlane update_and_commit # Also commit changes to Git. (git reset --hard HEAD^ to erase the last commit)
bundle exec fastlane validate          # Now validation will pass.
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
bundle exec rake
```

To automatically fix many of the styling issues, use
```
bundle exec rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
