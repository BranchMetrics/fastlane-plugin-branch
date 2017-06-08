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
gem install fastlane -NV
```

**Note:** If using the system Ruby, you must use `sudo`. However, using the system Ruby is not recommended. See
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

Once released, you can install this plugin using

```bash
fastlane add_plugin branch
```

That tries to install from Rubygems and will fail before release.

To install before release:

1. Add a `Gemfile` to your project with these contents:

  ```ruby
  source 'https://rubygems.org'

  gem "fastlane"

  plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
  eval_gemfile(plugins_path) if File.exist?(plugins_path)
  ```

1. Modify `/path/to/MyProject/fastlane/Pluginfile` to have these contents:

  ```ruby
  gem "fastlane-plugin-branch", git: "git@github.com/BranchMetrics/fastlane-plugin-branch"
  ```

  or

  ```ruby
  gem "fastlane-plugin-branch", path: "/where/I/checked/out/fastlane-plugin-branch"
  ```

1. Install the plugin

  ```ruby
  bundle install
  ```

**Note:** Before release, `fastlane` must always be run using `bundle exec fastlane <args>` in order
to use this plugin.

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

## validate_universal_links action

This action validates all Universal Link domains configured in a project without making any modification.
It validates both Branch and non-Branch domains.

```ruby
validate_universal_links
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `bundle install` and `bundle exec fastlane test`.

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

It is strongly recommended for all Ruby work to use a version manager, either [RVM](https://rvm.io) or
[rbenv](https://github.com/rbenv/rbenv).

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
