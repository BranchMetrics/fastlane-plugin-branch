# Branch plugin

Use this Fastlane plugin to set up your Xcode project configuration correctly to
use the Branch SDK. It can also validate the Universal Link configuration in any Xcode
project, for Branch domains as well as non-Branch domains. Unlike web-based Universal
Link validators, the `validate_universal_links` action
operates directly on your project. There is no need to look up your team identifier or
any other information. The validator requires no input at all for simple projects. It
supports both signed and unsigned apple-app-site-association files.

Also see the [Branch CLI](https://github.com/BranchMetrics/branch_io_cli), which
supports the same operations without Fastlane.

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

Integrates the Branch SDK into a native app project. This currently supports iOS only.
It will infer the project location if there is exactly one .xcodeproj anywhere under
the current directory, excluding any in a Pods or Carthage folder. Otherwise, specify
the project location using the `--xcodeproj` option, or the CLI will prompt you for the
location.

If a Podfile or Cartfile is detected, the Branch SDK will be added to the relevant
configuration file and the dependencies updated to include the Branch framework.
This behavior may be suppressed using `--no-add-sdk`. If no Podfile or Cartfile
is found, and Branch.framework is not already among the project's dependencies,
you will be prompted for a number of choices, including setting up CocoaPods or
Carthage for the project or directly installing the Branch.framework.

By default, all supplied Universal Link domains are validated. If validation passes,
the setup continues. If validation fails, no further action is taken. Suppress
validation using `--no-validate` or force changes when validation fails using
`--force`.

By default, this command will look for the first app target in the project. Test
targets are not supported. To set up an extension target, supply the `--target` option.

All relevant target settings are modified. The Branch keys are added to the Info.plist,
along with the `branch_universal_link_domains` key for custom domains (when `--domains`
is used). For app targets, all domains are added to the project's Associated Domains
entitlement. An entitlements file is also added for app targets if none is found.
Optionally, if `--frameworks` is specified, this command can add a list of system
frameworks to the target's dependencies (e.g., AdSupport, CoreSpotlight, SafariServices).

A language-specific patch is applied to the AppDelegate (Swift or Objective-C).
This can be suppressed using `--no-patch-source`.

#### Prerequisites

Before using this command, make sure to set up your app in the [Branch Dashboard](https://dashboard.branch.io). See https://docs.branch.io/pages/dashboard/integrate/ for details. To use the `setup` command, you need:

- Branch key(s), either live, test or both
- Domain name(s) used for Branch links
- Location of your Xcode project (may be inferred in simple projects)

If using the `--commit` option, `git` is required. If not using `--no-add-sdk`,
the `pod` or `carthage` command may be required. If not found, the CLI will
offer to install and set up these command-line tools for you. Alternately, you can arrange
that the relevant commands are available in your `PATH`.

```ruby
setup_branch(
  live_key: "key_live_xxxx",
  test_key: "key_test_yyyy",
  app_link_subdomain: "myapp",
  uri_scheme: "myscheme",
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

|Fastfile key|description|Environment variable|type|default value|
|---|---|---|---|---|
|:live_key|The Branch live key to use (:live_key or :test_key is required)|BRANCH_LIVE_KEY|string||
|:test_key|The Branch test key to use (:live_key or :test_key is required)|BRANCH_TEST_KEY|string||
|:app_link_subdomain|An app.link subdomain to use (:app_link_subdomain or :domains is required. The union of the two sets of domains will be used.)|BRANCH_APP_LINK_SUBDOMAIN|string||
|:domains|A list of domains (custom domains or Branch domains) to use (:app_link_subdomain or :domains is required. The union of the two sets of domains will be used.)|BRANCH_DOMAINS|array of strings or comma-separated string||
|:uri_scheme|A URI scheme to add to the manifest|BRANCH_URI_SCHEME|string||
|:xcodeproj|Path to a .xcodeproj directory to use. (:xcodeproj, :android_project_path or :android_manifest_path is required.)|BRANCH_XCODEPROJ|string||
|:target|Name of the target to use in the Xcode project (iOS only; optional)|BRANCH_TARGET|string||
|:validate|Determines whether to validate the resulting Universal Link configuration before modifying the project|BRANCH_VALIDATE|boolean|true|
|:force|Update project(s) even if Universal Link validation fails|BRANCH_FORCE_UPDATE|boolean|false|
|:commit|Set to true to commit changes to Git; set to a string to commit with a custom message|BRANCH_COMMIT_CHANGES|boolean or string|false|
|:frameworks|A list of system frameworks to add to the target that uses the Branch SDK (iOS only)|BRANCH_FRAMEWORKS|array|[]|
|:add_sdk|Set to false to disable automatic integration of the Branch SDK|BRANCH_ADD_SDK|boolean|true|
|:podfile|Path to a Podfile to update (iOS only)|BRANCH_PODFILE|string||
|:patch_source|Set to false to disable automatic source-code patching|BRANCH_PATCH_SOURCE|boolean|true|
|:pod_repo_update|Set to false to disable update of local podspec repo before pod install|BRANCH_POD_REPO_UPDATE|boolean|true|
|:cartfile|Path to a Cartfile to update (iOS only)|BRANCH_CARTFILE|string||
|:carthage_command|Command to use when installing with Carthage|BRANCH_CARTHAGE_COMMAND|string|update --platform ios|

Individually, all parameters are optional, but the following conditions apply:

- :live_key or :test_key must be specified.
- :app_link_subdomain or :domains must be specified.

If these parameters are not specified, you will be prompted for them.

This action also supports an optional Branchfile to specify configuration options.
See the sample [Branchfile](./fastlane/Branchfile) in the fastlane subdirectory of this repo.

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

|Fastfile key|description|Environment variable|type|default value|
|---|---|---|---|---|
|:xcodeproj|Path to a .xcodeproj directory to use|BRANCH_XCODEPROJ|string||
|:target|Name of the target to use in the Xcode project|BRANCH_TARGET|string||
|:domains|A list of domains (custom domains or Branch domains) that must be present in the project.|BRANCH_DOMAINS|array of strings or comma-separated string||

All parameters are optional. Without any parameters, the action looks for a single .xcodeproj
folder (with the exception of a Pods project) and reports an error if none or more than one is found.
It uses the first non-test, non-extension target in that project.

If the :domains parameter is not provided, validation will pass as long as there is at least
one Universal Link domain configured for the target, and all Universal Link domains pass
AASA validation. If the the :domains parameter is provided, the Universal Link domains in
the project must also match the value of this parameter without regard to order.

This action does not use the Branchfile.

## Examples

There is an example [Fastfile](./fastlane/Fastfile) in this repo that defines a number of
example lanes. Be sure to run `bundle install` before trying any of the examples.

### setup

This lane sets up the BranchPluginExample project
in
[examples/ios/BranchPluginExample](./examples/ios/BranchPluginExample).
The Xcode project uses CocoaPods and Swift.

```bash
bundle exec fastlane setup
```

### setup_and_commit

This lane sets up the BranchPluginExample projects and also commits the results to git.

```bash
bundle exec fastlane setup_and_commit
```

### setup_objc

This lane sets up the BranchPluginExampleObjc project
in [examples/ios/BranchPluginExampleObjc](./examples/ios/BranchPluginExampleObjc).
The project uses CocoaPods and Objective-C.

```bash
bundle exec fastlane setup_objc
```

### setup_carthage

This lane sets up the BranchPluginExampleCarthage project
in [examples/ios/BranchPluginExampleCarthage](./examples/ios/BranchPluginExampleCarthage).
The project uses Carthage and Swift.

```bash
bundle exec fastlane setup_carthage
```

### validate

This lane validates the Universal Link configuration for the BranchPluginExample
project in [examples/ios/BranchPluginExample](./examples/ios/BranchPluginExample).

```bash
bundle exec fastlane validate
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
