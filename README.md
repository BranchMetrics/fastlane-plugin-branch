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

<!-- The following is generated. Do not edit by hand. Run fastlane readme to -->
<!-- regenerate this section. -->
<!-- BEGIN ACTION REFERENCE -->
### setup_branch action

```Ruby
setup_branch
```

Integrates the Branch SDK into a native app project. This currently supports iOS only.
It will infer the project location if there is exactly one .xcodeproj anywhere under
the current directory, excluding any in a Pods or Carthage folder. Otherwise, specify
the project location using the `xcodeproj` option, or the CLI will prompt you for the
location.

If a Podfile or Cartfile is detected, the Branch SDK will be added to the relevant
configuration file and the dependencies updated to include the Branch framework.
This behavior may be suppressed using `add_sdk: false`. If no Podfile or Cartfile
is found, and Branch.framework is not already among the project's dependencies,
you will be prompted for a number of choices, including setting up CocoaPods or
Carthage for the project or directly installing the Branch.framework.

By default, all supplied Universal Link domains are validated. If validation passes,
the setup continues. If validation fails, no further action is taken. Suppress
validation using `validate: false` or force changes when validation fails using
`force`.

By default, this command will look for the first app target in the project. Test
targets are not supported. To set up an extension target, supply the `target` option.

All relevant target settings are modified. The Branch keys are added to the Info.plist,
along with the `branch_universal_link_domains` key for custom domains (when `domains`
is used). For app targets, all domains are added to the project's Associated Domains
entitlement. An entitlements file is also added for app targets if none is found.
Optionally, if `frameworks` is specified, this command can add a list of system
frameworks to the target's dependencies (e.g., AdSupport, CoreSpotlight, SafariServices).

A language-specific patch is applied to the AppDelegate (Swift or Objective-C).
This can be suppressed using `patch_source: false`.

#### Prerequisites

Before using this command, make sure to set up your app in the Branch Dashboard
(https://dashboard.branch.io). See https://docs.branch.io/pages/dashboard/integrate/
for details. To use the `setup` command, you need:

- Branch key(s), either live, test or both
- Domain name(s) used for Branch links
- Location of your Xcode project (may be inferred in simple projects)

If using the `commit` option, `git` is required. If not using `add_sdk: false`,
the `pod` or `carthage` command may be required. If not found, the CLI will
offer to install and set up these command-line tools for you. Alternately, you can arrange
that the relevant commands are available in your `PATH`.

All parameters are optional. A live key or test key, or both is required, as well
as at least one domain. Specify `live_key`, `test_key` or both and `app_link_subdomain`,
`domains` or both. If these are not specified, this command will prompt you
for this information.

See https://github.com/BranchMetrics/branch_io_cli#setup-command for more information.


#### Options

|Fastfile key|description|Environment variable|type|default value|
|---|---|---|---|---|
|live_key|Branch live key|BRANCH_LIVE_KEY|String||
|test_key|Branch test key|BRANCH_TEST_KEY|String||
|domains|Comma-separated list of custom domain(s) or non-Branch domain(s)|BRANCH_DOMAINS|Array||
|app_link_subdomain|Branch app.link subdomain, e.g. myapp for myapp.app.link|BRANCH_APP_LINK_SUBDOMAIN|String||
|uri_scheme|Custom URI scheme used in the Branch Dashboard for this app|BRANCH_URI_SCHEME|String||
|setting|Use a custom build setting for the Branch key (default: Use Info.plist)|BRANCH_SETTING|String||
|test_configurations|List of configurations that use the test key with a user-defined setting (default: Debug configurations)|BRANCH_TEST_CONFIGURATIONS|Array||
|xcodeproj|Path to an Xcode project to update|BRANCH_XCODEPROJ|String||
|target|Name of a target to modify in the Xcode project|BRANCH_TARGET|String||
|podfile|Path to the Podfile for the project|BRANCH_PODFILE|String||
|cartfile|Path to the Cartfile for the project|BRANCH_CARTFILE|String||
|carthage_command|Command to run when installing from Carthage|BRANCH_CARTHAGE_COMMAND|String|update --platform ios|
|frameworks|Comma-separated list of system frameworks to add to the project|BRANCH_FRAMEWORKS|Array||
|pod_repo_update|Update the local podspec repo before installing|BRANCH_POD_REPO_UPDATE|Boolean|true|
|validate|Validate Universal Link configuration|BRANCH_VALIDATE|Boolean|true|
|force|Update project even if Universal Link validation fails|BRANCH_FORCE|Boolean|false|
|add_sdk|Add the Branch framework to the project|BRANCH_ADD_SDK|Boolean|true|
|patch_source|Add Branch SDK calls to the AppDelegate|BRANCH_PATCH_SOURCE|Boolean|true|
|commit|Commit the results to Git if non-blank|BRANCH_COMMIT|String||
|confirm|Confirm configuration before proceeding|BRANCH_CONFIRM|Boolean|true|


#### Examples

```Ruby
setup_branch(
  live_key: "key_live_xxxx",
  test_key: "key_test_yyyy",
  app_link_subdomain: "myapp",
  uri_scheme: "myscheme",
  xcodeproj: "MyIOSApp.xcodeproj"
)

```




### validate_universal_links action

```Ruby
validate_universal_links
```

This command validates all Universal Link domains configured in a project without making any
modification. It validates both Branch and non-Branch domains. Unlike web-based Universal
Link validators, this command operates directly on the project. It finds the bundle and
signing team identifiers in the project as well as the app's Associated Domains. It requests
the apple-app-site-association file for each domain and validates the file against the
project's settings.

Only app targets are supported for this command. By default, it will validate the first.
If your project has multiple app targets, specify the `target` option to validate other
targets.

By default, all build configurations in the project are validated. To validate a different list
of configurations, including a single configuration, specify the `configurations` option.

If `domains` is specified, the list of Universal Link domains in the Associated
Domains entitlement must exactly match this list, without regard to order, for all
configurations under validation. If no `domains` are provided, validation passes
if at least one Universal Link domain is configured for each configuration and passes
validation, and no Universal Link domain is present in anyconfiguration that does not
pass validation.

All parameters are optional.

See https://github.com/BranchMetrics/branch_io_cli#validate-command for more information.


#### Options

|Fastfile key|description|Environment variable|type|default value|
|---|---|---|---|---|
|domains|Comma-separated list of domains to validate (Branch domains or non-Branch domains)|BRANCH_DOMAINS|Array|[]|
|xcodeproj|Path to an Xcode project to update|BRANCH_XCODEPROJ|String||
|target|Name of a target to validate in the Xcode project|BRANCH_TARGET|String||
|configurations|Comma-separated list of configurations to validate (default: all)|BRANCH_CONFIGURATIONS|Array||


#### Examples

```Ruby
validate_universal_links
```

```Ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj")
```

```Ruby
validate_universal_links(xcodeproj: "MyProject.xcodeproj", target: "MyProject")
```

```Ruby
validate_universal_links(domains: %w{example.com www.example.com})
```





### branch_report action

```Ruby
branch_report
```

This command optionally cleans and then builds a workspace or project, generating a verbose
report with additional diagnostic information suitable for opening a support ticket.

Use the `header_only` option to output only a brief diagnostic report without
building.


#### Options

|Fastfile key|description|Environment variable|type|default value|
|---|---|---|---|---|
|workspace|Path to an Xcode workspace|BRANCH_WORKSPACE|String||
|xcodeproj|Path to an Xcode project|BRANCH_XCODEPROJ|String||
|scheme|A scheme from the project or workspace to build|BRANCH_SCHEME|String||
|target|A target to build|BRANCH_TARGET|String||
|configuration|The build configuration to use (default: Scheme-dependent)|BRANCH_CONFIGURATION|String||
|sdk|Passed as -sdk to xcodebuild|BRANCH_SDK|String|iphonesimulator|
|podfile|Path to the Podfile for the project|BRANCH_PODFILE|String||
|cartfile|Path to the Cartfile for the project|BRANCH_CARTFILE|String||
|clean|Clean before attempting to build|BRANCH_CLEAN|Boolean|true|
|header_only|Write a report header to standard output and exit|BRANCH_HEADER_ONLY|Boolean|false|
|pod_repo_update|Update the local podspec repo before installing|BRANCH_POD_REPO_UPDATE|Boolean|true|
|out|Report output path|BRANCH_REPORT_PATH|String|./report.txt|
|confirm|Confirm before running certain commands|BRANCH_CONFIRM|Boolean|true|


#### Examples

```Ruby
branch_report
```

```Ruby
branch_report(header_only: true)
```

```Ruby
branch_report(workspace: "MyWorkspace.xcworkspace")
```





<!-- END ACTION REFERENCE -->

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
