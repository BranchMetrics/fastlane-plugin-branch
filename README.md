# branch plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg?style=flat-square)](https://rubygems.org/gems/fastlane-plugin-branch)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/settings-bundle/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/BranchMetrics/fastlane-plugin-branch.svg)](https://circleci.com/gh/BranchMetrics/fastlane-plugin-branch)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-branch`
before it is released:

### Install Fastlane

https://docs.fastlane.tools/getting-started/android/setup/  
https://docs.fastlane.tools/getting-started/ios/setup/

Before release, the packaged `fastlane` binary available in the zip and via Homebrew will not
work.

```bash
gem install fastlane
```

**Note:** If using the system Ruby, you must use `sudo`. However, using the system Ruby can cause
issues at times. See
[Notes on Ruby Version Managers](#notes-on-ruby-version-managers)

### Set up Fastlane for your project

**Option 1:** This may be easiest, but it requires more setup than is needed to try out this plugin.

```bash
fastlane init
```

**Option 2:** This is also easy and requires no further setup:

```bash
git checkout git@github.com:BranchMetrics/fastlane-plugin-branch
cp -r fastlane-plugin-branch/fastlane /path/to/MyProject
```

Then modify the parameters in `/path/to/MyProject/fastlane/Fastfile`.

### Install this plugin

```bash
fastlane add_plugin branch
```

That tries to install from RubyGems and will fail before release. You will be prompted
for a GitHub URL (git@github.com:BranchMetrics/fastlane-plugin-branch) or a local path
where you checked out the code. Once released, the plugin will be directly installed
from RubyGems with no further input required.

## setup_branch action

This action automatically configures Xcode and Android projects that use the Branch SDK
for Universal Links, App Links and custom URI handling. It modifies Xcode project settings and entitlements as well as Info.plist and AndroidManifest.xml files.

```ruby
setup_branch live_key: "key_live_xxxx",
             test_key: "key_test_yyyy",
   app_link_subdomain: "myapp",
           uri_scheme: "myscheme", # Android only
 android_project_path: "MyAndroidApp", # MyAndroidApp/src/main/AndroidManifest.xml
            xcodeproj: "MyIOSApp.xcodeproj"
```

Use the `:domains` parameter to specify custom domains, including non-Branch domains
```ruby
setup_branch live_key: "key_live_xxxx",
              domains: %w{example.com www.example.com}
            xcodeproj: "MyIOSApp.xcodeproj"
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

## validate_universal_links action (iOS only)

This action validates all Universal Link domains configured in a project without making any modification.
It validates both Branch and non-Branch domains.


```ruby
validate_universal_links
```

```ruby
validate_universal_links xcodeproj: "MyProject.xcodeproj"
```

```ruby
validate_universal_links xcodeproj: "MyProject.xcodeproj", target: "MyProject"
```

```ruby
validate_universal_links domains: %w{example.com www.example.com}
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

## Notes on Ruby Version Managers

The Ruby environment is notoriously troublesome. It is strongly recommended for
all Ruby work to use a version manager, either [RVM](https://rvm.io) or
[rbenv](https://github.com/rbenv/rbenv). A number of Fastlane actions have known
issues using the system Ruby because of SSL cert problems. This action mainly
modifies project files, so it is unlikely to have too much trouble with the
system Ruby. However, a non-Branch domain using PKCS7 for the AASA file might
run into similar issues with Universal Link validation.

### Streamlined RVM installation

```bash
\curl -sSL https://get.rvm.io | bash --ruby
```

Note the initial backslash, recommended to avoid shell aliases, but not entirely necessary.

Note that if GPG is detected, RVM will require a cert be installed in order to verify. On OS X:

```bash
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
```

```bash
gem install bundler
```

**Note:** When using RVM, all gems and binaries are installed under `~/.rvm`. Do not use `sudo`
to install or update gems or rubies.

Now the `bundle` command is available in your `PATH` under `~/.rvm`.
