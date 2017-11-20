# setup_branch


This action automatically configures Xcode projects that use the Branch SDK for Universal Links and custom URI handling. It modifies Xcode project settings and entitlements as well as Info.plist files. It also validates the Universal Link configuration for Xcode projects.




> Integrates the Branch SDK into a native app project. This currently supports iOS only.
It will infer the project location if there is exactly one .xcodeproj anywhere under
the current directory, excluding any in a Pods or Carthage folder. Otherwise, specify
the project location using the `xcodeproj` option, or the CLI will prompt you for the
location.
If a Podfile or Cartfile is detected, the Branch SDK will be added to the relevant
configuration file and the dependencies updated to include the Branch framework.
This behavior may be suppressed using `no_add_sdk`. If no Podfile or Cartfile
is found, and Branch.framework is not already among the project's dependencies,
you will be prompted for a number of choices, including setting up CocoaPods or
Carthage for the project or directly installing the Branch.framework.
By default, all supplied Universal Link domains are validated. If validation passes,
the setup continues. If validation fails, no further action is taken. Suppress
validation using `no_validate` or force changes when validation fails using
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
This can be suppressed using `no_patch_source`.
#### Prerequisites
Before using this command, make sure to set up your app in the Branch Dashboard
(https://dashboard.branch.io). See https://docs.branch.io/pages/dashboard/integrate/
for details. To use the `setup` command, you need:
- Branch key(s), either live, test or both
- Domain name(s) used for Branch links
- Location of your Xcode project (may be inferred in simple projects)
If using the `commit` option, `git` is required. If not using `no_add_sdk`,
the `pod` or `carthage` command may be required. If not found, the CLI will
offer to install and set up these command-line tools for you. Alternately, you can arrange
that the relevant commands are available in your `PATH`.
All parameters are optional. A live key or test key, or both is required, as well
as at least one domain. Specify `live_key`, `test_key` or both and `app_link_subdomain`,
`domains` or both. If these are not specified, this command will prompt you
for this information.
See https://github.com/BranchMetrics/branch_io_cli#setup-command for more information.



setup_branch |
-----|----
Supported platforms | ios
Author | @Branch <integrations@branch.io>, @Jimmy Dee <jgvdthree@gmail.com>



**1 Example**

```ruby
setup_branch(
  live_key: "key_live_xxxx",
  test_key: "key_test_yyyy",
  app_link_subdomain: "myapp",
  uri_scheme: "myscheme",
  xcodeproj: "MyIOSApp.xcodeproj"
)

```





**Parameters**

Key | Description
----|------------
  `live_key` | Branch live key
  `test_key` | Branch test key
  `domains` | Comma-separated list of custom domain(s) or non-Branch domain(s)
  `app_link_subdomain` | Branch app.link subdomain, e.g. myapp for myapp.app.link
  `uri_scheme` | Custom URI scheme used in the Branch Dashboard for this app
  `setting` | Use a custom build setting for the Branch key (default: Use Info.plist)
  `test_configurations` | List of configurations that use the test key with a user-defined setting (default: Debug configurations)
  `xcodeproj` | Path to an Xcode project to update
  `target` | Name of a target to modify in the Xcode project
  `podfile` | Path to the Podfile for the project
  `cartfile` | Path to the Cartfile for the project
  `carthage_command` | Command to run when installing from Carthage
  `frameworks` | Comma-separated list of system frameworks to add to the project
  `pod_repo_update` | Update the local podspec repo before installing
  `validate` | Validate Universal Link configuration
  `force` | Update project even if Universal Link validation fails
  `add_sdk` | Add the Branch framework to the project
  `patch_source` | Add Branch SDK calls to the AppDelegate
  `commit` | Commit the results to Git if non-blank
  `confirm` | Confirm configuration before proceeding




<hr />
To show the documentation in your terminal, run
```no-highlight
fastlane action setup_branch
```

<a href="https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/setup_branch.rb" target="_blank">View source code</a>

<hr />

<a href="/actions"><b>Back to actions</b></a>
